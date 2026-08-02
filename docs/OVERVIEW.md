# Dotfiles overview

This is a macOS-focused, chezmoi-managed environment. A fresh machine starts
with `bootstrap.sh`; normal maintenance uses `chezmoi diff` and `chezmoi apply`.

## Design boundaries

- **Managed state** lives in the repository and should be reproducible from a
  clean account: shell/editor/terminal configuration, the Brewfile, Mise tools,
  macOS defaults, and small helper commands.
- **Runtime-owned state** is preserved with chezmoi `modify_` scripts where an
  application also writes its own file. Claude, Pi, and Herdr settings use this
  pattern and their modifiers are tested for idempotence.
- **Secrets** are never committed or rendered into generated configuration.
  Interactive Fish sessions load API credentials directly from 1Password on
  personal machines or Keeper on work machines. `load-ai-secrets` forces a
  refresh in the current shell.

## Layout

- `.chezmoidata/` — non-secret shared data such as macOS defaults and
  integration metadata.
- `.chezmoitemplates/` — reusable internal templates, currently the Brewfile.
- `dot_*` / `private_dot_*` — files deployed into the home directory.
- `run_*` — convergent setup and migration scripts executed by chezmoi.
- `scripts/check` — repository-only validation for both machine profiles.
- `docs/` — design and troubleshooting notes; not deployed.

## Bootstrap and packages

`bootstrap.sh` installs Xcode Command Line Tools, Homebrew, chezmoi, and Keeper
when the selected profile needs it. Package installation is declared once in
`.chezmoitemplates/Brewfile.tmpl`; the same content is deployed as `~/.Brewfile`
and embedded in the strict pre-apply package runner. A failed bundle therefore
stops `chezmoi apply` and is retried on the next run.

Global runtimes are declared in `~/.config/mise/config.toml` and follow latest.
Homebrew packages, GitHub extensions, Herdr plugins, LTUI, the Yazi flavor, and
Mise tools are refreshed by recurring scripts on every apply. Neovim plugins
likewise follow upstream rather than a committed lockfile.

## Shell and AI helpers

Fish is the primary shell. Zsh is the fuller fallback; Bash receives only a
minimal prompt/tool initialisation. Shell routing integrates Claude with cmux
and Herdr while preventing inherited cmux variables from causing recursion.

The Fish AI helpers are split by responsibility:

- `halp` / `h` suggests, revises, explains, or debugs shell commands.
- Enter places a suggestion back onto the normal Fish command line for review.
  Explicit execution uses `e`; recognised destructive commands require typing
  `EXECUTE` before they run.
- `q` provides lightweight general Q&A.
- `__ai_models`, `__ai_spin`, `__ai_log`, and the danger helpers are shared,
  independently autoloaded implementation functions.
- `build-env.sh` records installed tools and discovers work LiteLLM models.

## Application configuration

- Neovim uses LazyVim with explicitly declared extras and focused files under
  `lua/plugins/`.
- Ghostty is primary. Kitty remains as a minimal fallback, using the same Tokyo
  Night family without vendoring Kitty's full default configuration.
- Git uses delta, SSH signing through 1Password on personal machines, rebased
  pulls, autostash, rerere, and histogram diffs.
- Herdr plugin sources follow their default branches; Claude and Herdr
  integrations are repaired idempotently after apply.

## Validation

Run `scripts/check` before committing. It renders every template against fake
personal and work profiles, parses shell/Fish/Lua/JSON/TOML/YAML where relevant,
checks modifier idempotence, scans for common secret formats, and runs
`git diff --check`. It does not install packages, contact vaults, or mutate the
home directory.
