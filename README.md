# Dotfiles

Personal and work macOS configuration managed with
[chezmoi](https://www.chezmoi.io/). Fish is the primary shell, Ghostty the
primary terminal, and Neovim/LazyVim the primary editor. Homebrew manages system
packages and Mise manages language runtimes.

For more detail about the repository boundaries and individual components, see
[`docs/OVERVIEW.md`](docs/OVERVIEW.md).

## Fresh-machine setup

The bootstrap installs Xcode Command Line Tools, Homebrew, chezmoi, and—when a
work profile is selected—the Keeper CLI. It then clones and applies this repo:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/daffydowden/dotfiles/main/bootstrap.sh)"
```

The bootstrap asks whether this is a work machine. Work machines also prompt
for non-secret local metadata such as endpoints, cluster names, and the work
binary directory. API credentials remain in Keeper or 1Password rather than
being written into chezmoi data.

## Existing-machine workflow

Pull changes and inspect them before applying:

```bash
cd ~/.local/share/chezmoi
git pull
scripts/check
chezmoi diff
chezmoi apply
```

When `.chezmoi.toml.tmpl` changes, regenerate the local chezmoi configuration
before applying:

```bash
chezmoi init
chezmoi diff
chezmoi apply
```

Useful commands:

```bash
chezmoi cd                 # enter the source repository
chezmoi status             # show pending managed changes and runnable scripts
chezmoi diff               # preview changes to the home directory
chezmoi apply              # converge the machine
chezmoi verify             # verify managed files after applying
scripts/check              # validate the repository without applying it
```

`chezmoi status` normally lists unconditional `run_after_` scripts with an `R`;
that does not mean a managed file has drifted.

## One-time work-machine migration

Run this after pulling commit `a5bba2c` or any later version of the repository.
It removes the old cached work tokens, installs the session-based Keeper loader,
and restarts Fish so credentials retained by the previous shell are discarded:

```fish
cd ~/.local/share/chezmoi
git pull
scripts/check
chezmoi init
chezmoi diff
chezmoi apply
exec fish
load-ai-secrets
chezmoi verify
```

`load-ai-secrets` should complete without output. If it reports unavailable
Keeper records, authenticate or unlock Keeper and run it again.

Confirm the old cached fields have been removed:

```fish
rg 'src_access_token|jira_token|litellm_api_key' ~/.config/chezmoi/chezmoi.toml
```

The command should print nothing. Existing shells may still contain inherited
credentials until they are restarted.

## Secrets

Interactive Fish sessions load credentials directly into the current process:

- Personal machines use API Credential items in the `Personal` 1Password vault.
- Work machines use the configured Keeper records.
- `load-ai-secrets` clears and refreshes credentials in the current Fish shell.

Credentials are not rendered into managed shell configuration and are not
stored as Fish universal variables. A newly opened terminal may therefore need
the relevant password-manager application or CLI session to be unlocked.

## Updating dotfiles

Edit files in `~/.local/share/chezmoi`, then validate and preview:

```bash
cd ~/.local/share/chezmoi
scripts/check
chezmoi diff
```

Apply locally once the diff looks correct:

```bash
chezmoi apply
chezmoi verify
```

Commit source changes only after validation. Files under `docs/`, `scripts/`,
and this README are repository-only and are excluded from deployment.

## Repository map

- `.chezmoidata/` — non-secret shared data and pinned integration revisions.
- `.chezmoitemplates/` — reusable templates, including the canonical Brewfile.
- `dot_*` and `private_dot_*` — files rendered into the home directory.
- `run_*` — package setup, cache rebuilds, integrations, and migrations.
- `private_dot_config/private_fish/` — primary shell configuration and helpers.
- `private_dot_config/nvim/` — LazyVim configuration.
- `dot_claude/`, `dot_codex/`, and `private_dot_agents/` — agent configuration.
- `scripts/check` — personal/work template rendering and static validation.
- `docs/` — architecture and historical implementation notes.

## Version policy

This setup deliberately follows upstream for selected tools and Neovim plugins.
Entries marked `latest` and the absence of a committed Lazy lockfile are
intentional; use normal update commands when you want to pull newer versions.
Herdr plugin sources and the Yazi theme remain pinned where exact revisions are
useful for integration stability.
