# cmux claude-teams: the hooks vs split-panes trade-off (and why `bin/executable_claude` exists)

**TL;DR — do NOT naively retire `bin/executable_claude` (the `~/bin/claude` shim).**
It bridges a real gap: with stock cmux, you can have split-pane teammates *or*
cmux notifications/Feed, but **not both** from a single launch path. The shim is
the only thing that gives both.

## The trade-off (proven 2026-06-26 by `ps eww` on two live sessions)

| Launch path | faked `TMUX` → split-pane teammates | `--settings` / `CMUX_CLAUDE_HOOK_CMUX_BIN` → notifications + Feed |
|---|---|---|
| **`cmux claude-teams`** (the `c`/`claude` alias) | ✓ | ✗ |
| **bare `claude`** → resolves cmux-cli-shims `cmux-claude-wrapper` | ✗ (in-process teammates) | ✓ |

- `cmux claude-teams` fakes `TMUX` and installs `~/.cmuxterm/claude-teams-bin`,
  so teammates open as native cmux split panes — **but** it resolves the real
  binary directly, *skipping* the `cmux-claude-wrapper` that injects the hook
  bridge. Result: split panes, **no notifications**.
- bare `claude` resolves the wrapper (cli-shims dir is ~PATH position 2 inside a
  cmux surface), which injects `--settings {SessionStart,Stop,Notification,Feed,…}`
  and sets `CMUX_CLAUDE_HOOK_CMUX_BIN`. Result: hooks/notifications, **but no
  faked tmux → teammates run in-process, not split panes**.

## What the shim does

`cmux claude-teams` (faked tmux) → resolves `~/bin/claude` (this shim; its header
deliberately differs from cmux's wrapper signature so claude-teams does NOT skip
it) → execs `cmux-claude-wrapper` (injects `--settings`) → real claude.
Net: **split panes + hooks together.**

## History / honesty note

- Retired 2026-06-26 on the (wrong) reasoning "0.64.17 injects hooks natively, so
  the shim is redundant." That conclusion came from a single misread process
  (pid 83220) and skipped verifying the trade-off above. **Restored same day.**
- Earlier throwaway hypotheses that turned out WRONG: "fresh-vs-resume decides
  hooks" (a *resumed* session, pid 78012, had hooks; the discriminator is the
  launch path, not resume).

## VERIFIED 2026-06-26 (controlled A/B in fresh cmux workspaces)

Same launch (`cmux claude-teams`, fresh workspace), only variable = the shim:
- shim **retired** (pid 7024): `--settings` **ABSENT**.
- shim **restored** (pid 10840): `--settings` **PRESENT** + `CMUX_CLAUDE_HOOK_CMUX_BIN`
  set + `TMUX` faked + `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`. i.e. **hooks AND
  split panes together.** `~/bin` was at PATH pos 13, ahead of `~/.local/bin` (15),
  so `cmux claude-teams` resolved the shim → wrapper → real claude.

This also explains the old anomaly (pid 83220 had both) — the shim was present then;
retiring it broke hooks; restoring it fixes them. The "shim was off-PATH" worry was
about the *resumed* session only (see below), not fresh launches.

## STILL OPEN — the resume gap

On a cmux **app-restore / resumed** session (pid 5056), `~/bin` was **absent** from
the PATH cmux used, so `cmux claude-teams --resume` resolved `~/.local/bin/claude`
directly and the shim did NOT engage → no hooks. cmux auto-resumes workspaces, so
this is the common case. Relying on `~/bin` PATH ordering is fragile.

**Robust fix attempt — FAILED, REVERTED 2026-06-26. DO NOT RETRY.**
Tried `defaults write com.cmuxterm.app claudeCodeCustomClaudePath -string "$HOME/bin/claude"`.
After a cmux **restart** it caused **infinite recursion**: cmux sets
`CMUX_CUSTOM_CLAUDE_PATH=~/bin/claude` → launches the shim → shim execs
`cmux-claude-wrapper` → **the wrapper also re-reads `CMUX_CUSTOM_CLAUDE_PATH`** and
re-execs the shim → loop, each pass appending another `--settings` until
`node: Argument list too long` / `cmux-claude-wrapper line 799: ~/bin/claude:
Argument list too long`. Broke all claude launches. Reverted via
`defaults delete com.cmuxterm.app claudeCodeCustomClaudePath` + the run-once script
now actively deletes it. **Lesson: `claudeCodeCustomClaudePath` must NOT point at
anything that routes back through the wrapper — i.e. it cannot be the shim.**

## RESOLUTION — verified post-restart 2026-06-26 (shim only, no custom-path)

After deleting the custom-path default and restarting cmux: **both this restored
session AND a fresh `cmux claude-teams` carry `--settings` + `CMUX_CLAUDE_HOOK_CMUX_BIN`
(hooks) AND `TMUX` (split panes), with no loop.** Mechanism: at launch, interactive
fish has `~/bin` ahead on PATH → `cmux claude-teams` resolves the shim → shim strips
its own `~/bin` from PATH and execs `cmux-claude-wrapper` (injects `--settings`) →
real claude; the faked `TMUX` from `cmux claude-teams` gives split panes.

**Shim fingerprint:** a session launched *through* the shim has `~/bin` ABSENT from
its env PATH (the shim removes it, lines 35-39 of `bin/executable_claude`). So
"`~/bin` absent + `--settings` present" = shim fired. ("`~/bin` absent + no
`--settings`" = shim did NOT fire, e.g. the pre-restore resumed session 5056.)

## RESUME-HOOK GAP — confirmed real, live, non-deterministic (UPSTREAM, not locally fixable)

Verified by inspecting live sessions after a cmux restart: of 9 app-restored teams
sessions, **2 had no `--settings`/hooks** (split panes but no notifications). Root
cause is cmux's restore mechanism, NOT the shim:
- **`cmux-agent-resume/claude-*.zsh`** injects `--settings` directly → always hooks.
- **`cmux-surface-resume/claude-*.zsh`** runs **bare `claude`** → hooks ONLY if
  `claude` resolves to the cmux-claude-wrapper at that moment; otherwise it resolves
  the real binary and gets no hooks. Observed surface-resume sessions split 4 hooked
  / 2 not — i.e. PATH-resolution-dependent and inconsistent.

The shim helps **fresh interactive launches** (fish alias → `cmux claude-teams` →
shim → wrapper, `~/bin` ahead) but does NOT reliably cover cmux's restore paths.

**No clean local fix:** shim (PATH-dependent on restore), custom-path (infinite
loop — see above), or hooks-in-settings.json (would cover everything but DOUBLE-FIRES
wherever cmux also injects `--settings`). The correct fix is upstream — cmux should
inject the hook bridge consistently on every restore path (#2229). Local best state:
shim restored (helps fresh + many launches); accept that some restored sessions may
lack notifications until cmux fixes it. Symptom to recognise: a restored teams
session with split panes but no notifications/Feed.

## Alternative fix (not chosen)

Put the cmux hook bridge directly into the managed `settings.json`. Fixes the
claude-teams path, but **double-fires** hooks on bare-claude/wrapper sessions
(which already inject `--settings`). The shim avoids that.

Related cmux issues: #2229 (no team-mode notifications), #2541 (no sidebar
session status), #4901 (enable teams in normal sessions — still open).
