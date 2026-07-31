# Dotfiles Overview

A [chezmoi](https://chezmoi.io)-managed macOS dotfiles repo. `chezmoi init --apply`
renders templates and runs the setup scripts to bring a fresh Mac to a known state.
Source root: `~/.local/share/chezmoi`. Bootstrap a new machine with `bootstrap.sh`.

## Repo Layout

- **Top level** — single-file configs (`dot_gitconfig.tmpl`, `dot_zshrc.tmpl`,
  `dot_vimrc`, `dot_bashrc`) and the `run_*` setup scripts.
- **`private_dot_config/`** → `~/.config/` — most app configs (fish, nvim, ghostty,
  kitty, tmux, bat, k9s, zed, starship, ccstatusline, worktrunk).
- **`dot_local/`** → `~/.local/` — `bin/` helper scripts and `share/ai/` (the `ai`
  suggester's env builder + system prompts).
- **`private_dot_pi/`** → `~/.pi/` — pi coding-agent settings template.
- **`.chezmoidata/`** — static data (`osx_default.yaml`) consumed by templates.
- **`docs/`** — design notes & plans (chezmoi-ignored, not deployed).

## chezmoi Naming Conventions

- `dot_` → leading `.` (e.g. `dot_zshrc` → `~/.zshrc`).
- `private_` → file/dir gets `0600`/`0700` perms.
- `executable_` → file gets `+x`.
- `empty_` → keep a zero-byte file; `*.keep` → keep an otherwise-empty dir.
- `.tmpl` → Go-template rendered with chezmoi data (`.is_work`, `.chezmoi.os`,
  secrets, etc.).
- `run_once_` / `run_onchange_` + `before_`/`after_` → setup scripts (see below).

## Config Domains

- **Shell** — fish is primary (`private_fish/config.fish.tmpl` + `functions/`),
  with zsh/bash mirrors. Shared: starship prompt, zoxide, `nvim` as `$EDITOR`,
  `grep`→`ug` (ugrep), worktrunk shell init, and `claude` aliases that route
  through `cmux claude-teams` when inside a cmux workspace.
- **Editor** — Neovim on LazyVim (`nvim/lua/plugins/*`, heavy on AI plugins:
  avante, claudecode, codecompanion, parrot, magenta). Zed and a minimal
  `dot_vimrc` as backups.
- **Terminal** — Ghostty (primary) and Kitty, both themed tokyonight; tmux config.
- **Git** — `dot_gitconfig.tmpl`: delta pager, `gh` credential helper, rebase-pull,
  autostash, rerere, zdiff3, histogram diff, and a set of short aliases.
- **Tooling** — mise (runtime versions), k9s (+skin), bat (+vendored themes),
  worktrunk (`wt`), ccstatusline. Work machines additionally get Sourcegraph,
  Jira, LiteLLM, and k8s env vars from the `.is_work` template branch.

## The `ai` Suite (fish)

A pi-backed shell assistant under `private_fish/functions/` + `dot_local/share/ai/`:

- **`halp` / `h`** — env-aware command suggester with `describe`, `tldr`, and a
  no-arg "debug previous command" mode. Cycles through models, logs outcomes to
  `~/.local/share/ai/history.jsonl`, and surfaces recent failures back to the model.
- **`q`** — general one-shot question asker with follow-up/model-cycle.
- **`build-env.sh`** — introspects the live system (brew, mise, versions) into
  `~/.cache/ai/env.txt` so suggestions match the actual machine; self-heals on drift.
- **`system-prompts/`** — the prompt text for each mode.

## Run Scripts

- **`bootstrap.sh`** — one-time manual bootstrap: Xcode CLT → Homebrew → keeper-cli →
  chezmoi → `chezmoi init --apply daffydowden/dotfiles`.
- **`run_onchange_before_install-packages-darwin.sh.tmpl`** — the Brewfile; installs
  all formulas/casks/MAS apps via `brew bundle`.
- **`run_once_after_mise.sh.tmpl`** — pins global mise runtimes (node, bun, python,
  rust, ruby, java, uv).
- **`run_onchange_darwin-defaults.sh.tmpl`** — applies `macos defaults` from
  `.chezmoidata/osx_default.yaml` (Dock, Finder, key-repeat, hotkeys), gated by
  macOS major version.
- **`run_onchange_after_1password.sh.tmpl`** — (personal only) checks that the
  1Password CLI is authenticated, then pulls API keys out of the `Personal` vault
  into universal fish vars.
- **`run_onchange_after_bat-cache.sh.tmpl`** — rebuilds bat theme cache when themes change.
- **`run_onchange_after_ai-env-cache.sh.tmpl`** — rebuilds the `ai` env cache when
  the Brewfile changes.

## Other Notable Pieces

- **`dot_local/bin/wt-claude` / `wt-agent-marker`** — worktrunk wrappers that no-op
  marker commands outside a git repo.
- **`private_dot_ssh/config.tmpl`** — points SSH at the 1Password agent for all
  hosts, and includes colima's generated host entries. Private keys live in the
  vault, not on disk.

## Gotchas

Fragility risks flagged in the repo audit (task #1). Be aware when editing/applying:

**Critical**

- **Brew bundle fails silently** — `install-packages-darwin.sh.tmpl` lacks `set -e`,
  and a failed `brew bundle` only warns to stderr while exiting `0`, so chezmoi sees
  success despite partial package installs. Check brew output manually after apply.
- **Bootstrap doesn't verify keeper** — `bootstrap.sh` doesn't confirm
  `keeper-commander` installed before running `chezmoi init`, which needs it for work
  secrets; a failed install surfaces as a confusing init error.
- **Work secrets are unvalidated** — `.chezmoi.toml.tmpl`'s `keeperFindPassword`
  calls (Sourcegraph/Jira/LiteLLM) have no error handling; empty values silently
  break downstream tools.

**High**

- **Hardcoded model versions** — `private_dot_pi/.../modify_settings.json.tmpl` pins
  exact model IDs (`claude-sonnet-4-6-…`, `gpt-5.4-nano`) that will drift/deprecate.
- **Hardcoded `claude` CLI flags** — `worktrunk/config.toml`'s commit-message command
  assumes a stable CLI API (`--model=haiku --tools='' --disable-slash-commands`);
  no version guard if the CLI changes.

Full file:line detail and suggested fixes live in task #1's description.
