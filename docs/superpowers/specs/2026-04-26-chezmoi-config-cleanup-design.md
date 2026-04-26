# Chezmoi Config Cleanup — Design

Date: 2026-04-26
Scope: Tighten the chezmoi-managed dotfiles (excluding the already-modernised
Neovim config). Remove dead/legacy config, modernise where defaults have
shifted, and standardise tooling around shells, AI CLIs, and git.

## Goals

- Remove cruft: dead vim plugin manager, unused Sourcetree config, redundant
  global gitignore, oh-my-zsh boilerplate, abandoned helper scripts.
- Modernise: switch from `asdf-uv` fork to mise's first-party `uv`, adopt
  `git-delta`, add modern git defaults, align AI tooling with what's actually
  used.
- Make the lightweight `vim` and `zsh` paths usable again without conflicting
  with Neovim/fish (which remain primary).
- Stay portable across work and personal machines via existing `is_work` flag.

## Out of scope (deferred / explicit non-goals)

- Neovim config (already modernised).
- Tmux config — keep `private_dot_config/tmux/powerline` as-is. Will revisit
  separately when reintroducing tmux.
- aichat → pi.dev migration. Pi has `-p` one-shot but no `aichat -e`-style
  execute/revise/copy flow. Decision deferred; both will coexist for now.
- Manual cleanup of hand-installed `.app`s (chatbox, goose, lobehub) — user
  will do this outside chezmoi.

## Components and changes

### 1. Brewfile (`run_onchange_before_install-packages-darwin.sh.tmpl`)

**Remove**

- `brew "aider"` — replaced by other AI tools.

**Add**

- `brew "pi-coding-agent"` — for one-shot prompting via `pi -p`. (Formula
  is in homebrew/core, no tap needed.)
- `brew "git-delta"` — syntax-highlighting pager for git diff/log/blame.

**Keep (explicit decisions)**

- `cask "codex"` and `cask "codex-app"` — distinct (CLI vs GUI), both used.
- All six nerd-font casks — user wants the variety available.
- `cask "kitty"` and `cask "ghostty"` — both used (cmux uses libghostty).

### 2. Shell configs

**`dot_zshrc.tmpl`** — strip dead oh-my-zsh boilerplate (~30 lines of commented
options, autojump fallback). Keep:

- `printf '\33c\e[3J'` (suppress last-login)
- `DEFAULT_USER='{{ .chezmoi.username }}'`
- `alias grep=ug`
- claude/cmux alias block (mirrors fish)
- `[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh`
- `eval "$(starship init zsh)"`
- `eval "$(zoxide init zsh)"` (parity with fish, currently missing)
- lm-studio path block (parity with bash/fish)
- `wt` shell init (parity with bash)

Outcome: ~25 lines, mirrors `config.fish.tmpl` structure.

**`dot_bashrc`** — leave minimal (bash is script-only). Already correct.

**Fish (`config.fish.tmpl`)** — no changes; already clean. Keep `.keep`
placeholders in `conf.d/` and `completions/` for future use.

### 3. Editor configs

**`dot_vimrc`** — full rewrite as ~30-line "good defaults" config for
single-file edits. No plugin manager, no Vundle. Sane defaults only:

- `set nocompatible`, `filetype plugin indent on`, `syntax on`
- `set number relativenumber ruler ignorecase smartcase incsearch hlsearch`
- `set autoread hidden wildmenu wildmode=list:longest`
- `set tabstop=2 shiftwidth=2 expandtab`
- `set scrolloff=3 backspace=indent,eol,start`
- `set undofile undodir=~/.vim/undo` (with mkdir guard)
- `set clipboard=unnamed` (system clipboard)
- `set termguicolors background=dark`
- Path-based fuzzy find: `set path+=**` + `set wildignore+=*/node_modules/*,*/dist/*`
- Leader = `,`, a few practical mappings (clear search, write/quit shortcuts)
- Comment block documenting that vim 8+ packages can be dropped in
  `~/.vim/pack/<group>/start/` if plugins ever needed.

**Delete `run_once_after_vim_packages.sh.tmpl`** — Vundle bootstrap, dead.

### 4. Stale config deletions

- **None for tmux** (keeping per user).
- Nothing else flagged for deletion at this pass.

### 5. Kitty alignment

Update `private_dot_config/kitty/kitty.conf` to match Ghostty's UX where
sensible:

- Switch theme from `1984` to `tokyonight` (matches `current-theme.conf`).
- `scrollback_lines 20000` (already set; keep).
- Keep `mouse_map right press ungrabbed mouse_select_command_output`
  (kitty-specific feature, useful).
- Keep `tab_bar_style powerline` (kitty-only).

Replace `current-theme.conf` content with a tokyonight kitty theme matching
the ghostty palette.

### 6. Git config (`dot_gitconfig.tmpl`)

**Remove**

- `[difftool "sourcetree"]` and `[mergetool "sourcetree"]` stanzas.
- `askpass = git-gui--askpass` from `[core]` (legacy, not used with gh helper).

**Add modern defaults**

```ini
[core]
    pager = delta
[interactive]
    diffFilter = delta --color-only
[delta]
    navigate = true
    line-numbers = true
    syntax-theme = tokyonight_night
[merge]
    conflictStyle = zdiff3
[diff]
    colorMoved = default
    algorithm = histogram
[pull]
    rebase = true
[push]
    autoSetupRemote = true
    default = simple
[rerere]
    enabled = true
[branch]
    sort = -committerdate
[column]
    ui = auto
[fetch]
    prune = true
    pruneTags = true
[rebase]
    autoSquash = true
    autoStash = true
```

**Delete `dot_gitignore`** — duplicate of `dot_gitignore_global`; the
`excludesfile` in gitconfig points at `~/.gitignore_global` only. Avoids
confusion.

### 7. Bat / delta theme alignment (tokyonight)

Bat does not ship a tokyonight theme. To align bat (currently `Coldark-Dark`)
and delta (`syntax-theme`) with the tokyonight palette used in ghostty/zed:

- Add `private_dot_config/bat/themes/tokyonight_night.tmTheme` (sourced from
  the folke/tokyonight Sublime export, vendored into the chezmoi repo so the
  config is self-contained — no network at apply time).
- Add `run_once_after_bat-cache.sh.tmpl` that runs `bat cache --build` so the
  new theme is registered.
- Update `private_dot_config/bat/config` `--theme="tokyonight_night"`.
- Gitconfig `[delta] syntax-theme = tokyonight_night` (already in section 6).

### 8. mise bootstrap (`run_once_after_mise.sh.tmpl`)

Replace third-party `asdf-uv` plugin install with first-party mise tool:

```bash
# was:
mise plugin add uv https://github.com/b1-luettje/asdf-uv.git
mise install uv@latest

# becomes:
mise use -g uv@latest
```

Keep poetry plugin add line (still required as a plugin).
Keep `mise settings set python.uv_venv_auto true`.

## Migration notes / one-time manual steps

The following are user-action items (not chezmoi-managed):

- Manually uninstall hand-installed `.app`s: chatbox, goose, lobehub.
- After `chezmoi apply`: `brew uninstall aider`. The Brewfile no longer
  installs it but `brew bundle` is non-destructive.
- After `chezmoi apply`: `brew bundle cleanup --file=...` if the user wants
  to remove fonts/casks no longer in the Brewfile (none in this pass, but
  worth knowing).

## Risks / things to verify after apply

- `git-delta` interaction with `pager.diff = false` if user has any per-repo
  override (none observed in current chezmoi config).
- `pull.rebase = true` is a behaviour change — user should be aware.
- Vim undofile dir creation must be guarded (mkdir if not exists).
- Tokyonight kitty theme palette must match ghostty's exactly to keep parity.

## Loop-backs (tracked, not in this spec)

1. **aichat → pi migration** — needs more investigation; pi lacks the
   execute/revise/copy flow.
2. **Tmux config** — current `powerline` file is a 2017 tmuxline artifact
   with no `tmux.conf`. Will design a fresh tmux setup later.
3. **Kitty theme parity** — if any drift from ghostty tokyonight is noticed,
   resync.
