# Chezmoi Config Cleanup Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Tighten the chezmoi-managed dotfiles — remove cruft, modernise tooling, align colour palette to tokyonight, and make `vim`/`zsh` paths usable as secondary tools without conflicting with Neovim/fish.

**Architecture:** All edits live under `/Users/richarddowden/.local/share/chezmoi`. Templates use chezmoi's Go-template syntax with the existing `is_work` flag. Validation is done via `chezmoi execute-template <file>` for `.tmpl` files and `chezmoi diff` to preview the rendered change before commit. We commit after each task.

**Tech Stack:** chezmoi (Go templates), Brew bundle, fish/zsh/bash, Vim 8+, git, bat, delta, kitty, ghostty, mise.

---

## File Structure Map

**Modified:**

- `run_onchange_before_install-packages-darwin.sh.tmpl` — Brewfile: drop aider, add pi-coding-agent + git-delta.
- `dot_zshrc.tmpl` — strip oh-my-zsh boilerplate; add zoxide, lm-studio path, wt init.
- `dot_vimrc` — full rewrite as ~30-line plugin-free config.
- `dot_gitconfig.tmpl` — drop Sourcetree stanzas, add modern defaults + delta.
- `private_dot_config/bat/config` — switch to `tokyonight_night`.
- `private_dot_config/kitty/kitty.conf` — switch theme include comment to tokyonight (theme file replaced).
- `private_dot_config/kitty/current-theme.conf` — tokyonight palette.
- `run_once_after_mise.sh.tmpl` — replace asdf-uv with `mise use -g uv@latest`.

**Created:**

- `private_dot_config/bat/themes/tokyonight_night.tmTheme` — vendored tokyonight bat theme.
- `run_onchange_after_bat-cache.sh.tmpl` — rebuilds bat theme cache when any vendored theme file changes.

**Deleted:**

- `run_once_after_vim_packages.sh.tmpl` — Vundle bootstrap (dead).
- `dot_gitignore` — duplicate of `dot_gitignore_global`.

---

## Task 1: Brewfile updates (drop aider, add pi-coding-agent + git-delta)

**Files:**

- Modify: `run_onchange_before_install-packages-darwin.sh.tmpl`

- [ ] **Step 1: Edit Brewfile — remove aider line**

Open `run_onchange_before_install-packages-darwin.sh.tmpl` and delete the line:

```
brew "aider"
```

(currently appears in the `#--------- AI` block.)

- [ ] **Step 2: Edit Brewfile — add pi-coding-agent**

In the same `#--------- AI` block (after `brew "llm"`), add:

```
brew "pi-coding-agent"
```

- [ ] **Step 3: Edit Brewfile — add git-delta**

In the `#--------- Editors` block (just below `brew "git"`/`brew "gh"` block of the `#--------- Environment` section, where the other git tools live — `tig`, `lazygit`), add:

```
brew "git-delta"
```

So that section reads:

```
brew "git"
brew "gh"
brew "tig"
brew "lazygit"
brew "git-delta"
```

- [ ] **Step 4: Validate the template renders**

Run:

```bash
chezmoi execute-template < run_onchange_before_install-packages-darwin.sh.tmpl | grep -E '(aider|pi-coding-agent|git-delta)'
```

Expected output (no `aider`):

```
brew "git-delta"
brew "pi-coding-agent"
```

- [ ] **Step 5: Commit**

```bash
git add run_onchange_before_install-packages-darwin.sh.tmpl
git commit -m "Brewfile: drop aider, add pi-coding-agent and git-delta"
```

---

## Task 2: Delete dead Vundle bootstrap script

**Files:**

- Delete: `run_once_after_vim_packages.sh.tmpl`

- [ ] **Step 1: Delete the file**

```bash
git rm run_once_after_vim_packages.sh.tmpl
```

- [ ] **Step 2: Verify no other file references it**

```bash
grep -r "vim_packages" . --include='*.tmpl' --include='*.sh' --include='*.md' 2>/dev/null
```

Expected: no matches outside of git history.

- [ ] **Step 3: Commit**

```bash
git commit -m "Remove dead Vundle bootstrap script"
```

---

## Task 3: Rewrite `dot_vimrc` as a lightweight plugin-free config

**Files:**

- Modify (full rewrite): `dot_vimrc`

- [ ] **Step 1: Replace `dot_vimrc` contents**

Overwrite the entire file with the following content:

```vim
" Lightweight Vim config for quick single-file edits.
" Neovim is the primary editor — this file intentionally avoids plugins so
" `vim` stays fast and conflict-free with the LazyVim setup under nvim.
"
" To add a plugin without a manager (Vim 8+):
"   git clone <repo> ~/.vim/pack/plugins/start/<name>
" Plugins under start/ are auto-loaded. Use opt/ + :packadd for lazy loads.

set nocompatible
filetype plugin indent on
syntax on

" UI
set number
set relativenumber
set ruler
set showcmd
set showmode
set laststatus=2
set scrolloff=3
set termguicolors
set background=dark
set title
set visualbell

" Editing
set backspace=indent,eol,start
set hidden
set autoread
set tabstop=2
set shiftwidth=2
set expandtab
set clipboard=unnamed

" Search
set ignorecase
set smartcase
set incsearch
set hlsearch

" Wildmenu / fuzzy file find via :find
set wildmenu
set wildmode=list:longest
set path+=**
set wildignore+=*/node_modules/*,*/dist/*,*/tmp/*,*.swp,*.zip

" Persistent undo
set undofile
let &undodir = expand('~/.vim/undo')
if !isdirectory(&undodir) | call mkdir(&undodir, 'p', 0700) | endif

" No swap clutter
set nobackup
set nowritebackup
let &dir = expand('~/.vim/swap')
if !isdirectory(&dir) | call mkdir(&dir, 'p', 0700) | endif

" Leader mappings
let mapleader = ","
nnoremap <silent> <leader><space> :nohlsearch<CR>
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>

" British English spell
set spelllang=en_gb
nnoremap <silent> <leader>s :set spell!<CR>
```

- [ ] **Step 2: Validate vim parses the file without errors**

Run:

```bash
vim -u dot_vimrc -c 'qall' && echo OK
```

Expected: `OK` (vim exits cleanly with no error output).

- [ ] **Step 3: Commit**

```bash
git add dot_vimrc
git commit -m "Rewrite vimrc as plugin-free quick-edit config"
```

---

## Task 4: Rewrite `dot_zshrc.tmpl`

**Files:**

- Modify (full rewrite): `dot_zshrc.tmpl`

- [ ] **Step 1: Replace `dot_zshrc.tmpl` contents**

Overwrite the entire file with:

```sh
# Suppress last-login banner.
# https://stackoverflow.com/questions/15769615/remove-last-login-message-for-new-tabs-in-terminal
printf '\33c\e[3J'

DEFAULT_USER='{{ .chezmoi.username }}'

export EDITOR=nvim

alias grep='ug'

# Claude Code aliases — mirror config.fish.tmpl
if [ -n "$CMUX_WORKSPACE_ID" ]; then
    alias c='cmux claude-teams --dangerously-skip-permissions'
    alias claude='cmux claude-teams --dangerously-skip-permissions'
    alias claude-teams='cmux claude-teams'
    alias cy='claude --dangerously-skip-permissions'
else
    alias c='command claude --dangerously-skip-permissions'
    alias claude='command claude --dangerously-skip-permissions'
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

if [ -d "$HOME/.cache/lm-studio/bin" ]; then
    export PATH="$PATH:$HOME/.cache/lm-studio/bin"
fi

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi
```

- [ ] **Step 2: Validate template renders**

Run:

```bash
chezmoi execute-template < dot_zshrc.tmpl | head -5
```

Expected first line: `# Suppress last-login banner.`
Expected `DEFAULT_USER='richarddowden'` line present (no `{{ }}` escapes remain).

- [ ] **Step 3: Validate zsh syntax**

Run:

```bash
zsh -n <(chezmoi execute-template < dot_zshrc.tmpl) && echo OK
```

Expected: `OK`.

- [ ] **Step 4: Commit**

```bash
git add dot_zshrc.tmpl
git commit -m "zsh: strip oh-my-zsh boilerplate, mirror fish config"
```

---

## Task 5: Modernise `dot_gitconfig.tmpl` (delta, modern defaults, drop Sourcetree)

**Files:**

- Modify (full rewrite): `dot_gitconfig.tmpl`

- [ ] **Step 1: Replace `dot_gitconfig.tmpl` contents**

Overwrite the entire file with:

```ini
[user]
	name = Richard Dowden
	email = rd@richarddowden.com

[core]
	excludesfile = /Users/{{ .chezmoi.username }}/.gitignore_global
	editor = /opt/homebrew/bin/nvim
	autocrlf = input
	safecrlf = true
	pager = delta

[init]
	defaultBranch = main

[credential]
	helper = osxkeychain

[credential "https://github.com"]
	helper =
	helper = !/opt/homebrew/bin/gh auth git-credential

[credential "https://gist.github.com"]
	helper =
	helper = !/opt/homebrew/bin/gh auth git-credential

[help]
	autocorrect = 10

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

[alias]
	st = status
	s = status
	co = checkout
	c = commit -v
	b = branch
	d = diff
	p = pull
	a = add
	l = log
	pushed = !git cherry -v `git symbolic-ref HEAD 2> /dev/null`
	klog = log --graph --pretty=format:'%an: %s - %Cred%h%Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative
	stls = ls-files
	edit-unmerged = "!f() { git ls-files --unmerged | cut -f2 | sort -u ; }; nvim `f`"
	add-unmerged = "!f() { git ls-files --unmerged | cut -f2 | sort -u ; }; git add `f`"
	lc = log ORIG_HEAD.. --stat --no-merges
	who = log --pretty='format:%Cgreen%an%Creset\t%C(yellow)%ar%Creset\t%s ' --no-merges
	unstage = reset HEAD
```

- [ ] **Step 2: Validate template renders**

Run:

```bash
chezmoi execute-template < dot_gitconfig.tmpl | head -10
```

Expected `excludesfile = /Users/richarddowden/.gitignore_global` resolved (no template syntax left).

- [ ] **Step 3: Validate as a gitconfig**

Render to a temp file and run `git config -f` against it:

```bash
TMP=$(mktemp) && chezmoi execute-template < dot_gitconfig.tmpl > "$TMP" && git config -f "$TMP" --list >/dev/null && echo OK; rm "$TMP"
```

Expected: `OK` (no parse error from git).

- [ ] **Step 4: Commit**

```bash
git add dot_gitconfig.tmpl
git commit -m "gitconfig: add delta + modern defaults, drop Sourcetree"
```

---

## Task 6: Delete duplicate `dot_gitignore`

**Files:**

- Delete: `dot_gitignore`

- [ ] **Step 1: Confirm gitconfig points only at the global file**

```bash
grep excludesfile dot_gitconfig.tmpl
```

Expected: line references `~/.gitignore_global` only (matches Task 5 output). The home `~/.gitignore` is not referenced by the gitconfig.

- [ ] **Step 2: Delete `dot_gitignore`**

```bash
git rm dot_gitignore
```

- [ ] **Step 3: Commit**

```bash
git commit -m "Remove unused ~/.gitignore (dupe of ~/.gitignore_global)"
```

---

## Task 7: Vendor tokyonight tmTheme for bat/delta

**Files:**

- Create: `private_dot_config/bat/themes/tokyonight_night.tmTheme`

- [ ] **Step 1: Download the upstream theme into the repo**

```bash
mkdir -p private_dot_config/bat/themes
curl -fsSL \
  https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/sublime/tokyonight_night.tmTheme \
  -o private_dot_config/bat/themes/tokyonight_night.tmTheme
```

- [ ] **Step 2: Sanity-check the file**

```bash
file private_dot_config/bat/themes/tokyonight_night.tmTheme
head -3 private_dot_config/bat/themes/tokyonight_night.tmTheme
wc -l private_dot_config/bat/themes/tokyonight_night.tmTheme
```

Expected: file type "XML 1.0 document" (or "ASCII text"), first line `<?xml version="1.0" encoding="UTF-8"?>`, line count > 100.

- [ ] **Step 3: Commit**

```bash
git add private_dot_config/bat/themes/tokyonight_night.tmTheme
git commit -m "Vendor tokyonight_night tmTheme for bat/delta"
```

---

## Task 8: Add `run_onchange_after_bat-cache.sh.tmpl` to rebuild bat theme cache

**Files:**

- Create: `run_onchange_after_bat-cache.sh.tmpl`

- [ ] **Step 1: Create the run-onchange script**

Use `run_onchange_` so chezmoi re-runs it whenever any vendored theme changes. The hash comment changes when any file under `bat/themes/` changes, which makes chezmoi re-execute.

Write the following content to `run_onchange_after_bat-cache.sh.tmpl`:

```sh
{{- if eq .chezmoi.os "darwin" -}}
#!/bin/bash
set -e

# bat themes hash: {{ include "private_dot_config/bat/themes" | sha256sum }}
#
# Rebuild bat's theme cache so vendored themes under
# ~/.config/bat/themes/ become selectable via `--theme=...`.
if command -v bat >/dev/null 2>&1; then
    bat cache --build >/dev/null
fi
{{ end -}}
```

Note: `include` reads file contents; for a directory we hash a glob. If `include` on a directory errors at template-render time, fall back to a per-file include:

```sh
# bat themes hash: {{ include "private_dot_config/bat/themes/tokyonight_night.tmTheme" | sha256sum }}
```

- [ ] **Step 2: Validate template renders to valid bash**

```bash
chezmoi execute-template < run_onchange_after_bat-cache.sh.tmpl | bash -n && echo OK
```

Expected: `OK`. The rendered output should contain a literal `bat themes hash: <64-hex-chars>` comment.

- [ ] **Step 3: Commit**

```bash
git add run_onchange_after_bat-cache.sh.tmpl
git commit -m "Add run-onchange script to rebuild bat theme cache"
```

---

## Task 9: Switch bat config to tokyonight

**Files:**

- Modify: `private_dot_config/bat/config`

- [ ] **Step 1: Edit `private_dot_config/bat/config`**

Replace the line:

```
--theme="Coldark-Dark"
```

with:

```
--theme="tokyonight_night"
```

- [ ] **Step 2: Validate (post-apply will be tested via `bat --list-themes`; here just confirm content)**

```bash
grep -n '^--theme' private_dot_config/bat/config
```

Expected: `--theme="tokyonight_night"`.

- [ ] **Step 3: Commit**

```bash
git add private_dot_config/bat/config
git commit -m "bat: switch theme to tokyonight_night"
```

---

## Task 10: Replace kitty theme with tokyonight palette

**Files:**

- Modify (full rewrite): `private_dot_config/kitty/current-theme.conf`

- [ ] **Step 1: Replace `current-theme.conf` contents**

Overwrite the entire file with:

```conf
# tokyonight (night) — palette mirrors private_dot_config/ghostty/config.

foreground            #c8d3f5
background            #222436
selection_foreground  #c8d3f5
selection_background  #2d3f76

cursor                #c8d3f5
cursor_text_color     #222436

url_color             #82aaff
url_style             single

# black / red / green / yellow / blue / magenta / cyan / white
color0  #1b1d2b
color1  #ff757f
color2  #c3e88d
color3  #ffc777
color4  #82aaff
color5  #c099ff
color6  #86e1fc
color7  #828bb8

color8  #444a73
color9  #ff8d94
color10 #c7fb6d
color11 #ffd8ab
color12 #9ab8ff
color13 #caabff
color14 #b2ebff
color15 #c8d3f5

# Tab bar — dim grey for inactive, accent for active
active_tab_foreground   #c8d3f5
active_tab_background   #2d3f76
inactive_tab_foreground #828bb8
inactive_tab_background #1b1d2b
```

- [ ] **Step 2: Validate kitty does not error on the theme**

Run:

```bash
kitten icat --version >/dev/null 2>&1 && \
  kitty +runpy 'import sys; sys.exit(0)' --config private_dot_config/kitty/current-theme.conf && echo OK
```

If `kitty` is not on PATH at plan-execution time (kitty cask might not be re-installed yet), skip this and just confirm the file renders by:

```bash
grep -c '^color' private_dot_config/kitty/current-theme.conf
```

Expected: `16`.

- [ ] **Step 3: Commit**

```bash
git add private_dot_config/kitty/current-theme.conf
git commit -m "kitty: switch theme to tokyonight (matches ghostty palette)"
```

---

## Task 11: Update mise bootstrap to first-party uv

**Files:**

- Modify: `run_once_after_mise.sh.tmpl`

- [ ] **Step 1: Edit `run_once_after_mise.sh.tmpl`**

Find these lines:

```
mise plugin add poetry
mise plugin add uv https://github.com/b1-luettje/asdf-uv.git
mise install uv@latest

mise settings set python.uv_venv_auto true
```

Replace the block with:

```
mise plugin add poetry
mise use -g uv@latest

mise settings set python.uv_venv_auto true
```

- [ ] **Step 2: Validate template renders to valid bash**

```bash
chezmoi execute-template < run_once_after_mise.sh.tmpl | bash -n && echo OK
```

Expected: `OK`.

- [ ] **Step 3: Commit**

```bash
git add run_once_after_mise.sh.tmpl
git commit -m "mise: replace asdf-uv fork with first-party uv"
```

---

## Task 12: Final integration — `chezmoi diff` review and apply

**Files:** none modified — verification only.

- [ ] **Step 1: Diff the rendered changes against the live home directory**

```bash
chezmoi diff
```

Review the output. Confirm:

- `~/.zshrc` — boilerplate removed, zoxide line added.
- `~/.vimrc` — fully replaced, plugin-free.
- `~/.gitconfig` — Sourcetree blocks gone, delta/modern blocks present.
- `~/.gitignore` — to be deleted.
- `~/.config/bat/config` — theme line changed.
- `~/.config/bat/themes/tokyonight_night.tmTheme` — new.
- `~/.config/kitty/current-theme.conf` — palette replaced.

Expected: only intended changes appear. No accidental whitespace/template breakage.

- [ ] **Step 2: Apply the changes**

```bash
chezmoi apply
```

Expected: clean apply, no errors. The `run_onchange_after_bat-cache.sh.tmpl` script runs once now and re-fires on any future change to a vendored bat theme.

- [ ] **Step 3: Run a brew bundle pass to install delta and pi**

```bash
brew install git-delta pi-coding-agent
brew uninstall aider 2>/dev/null || true
```

(The next `chezmoi apply` will also re-run the brew bundle template, but installing directly here is faster.)

- [ ] **Step 4: Smoke-test each change**

Run each of these and confirm the expected output:

```bash
# delta
git -C . log -1 -p | head -20
# Expected: syntax-highlighted output from delta.

# bat tokyonight
bat --list-themes | grep -i tokyonight
# Expected: `tokyonight_night` listed.
bat private_dot_config/ghostty/config | head -5
# Expected: tokyonight-styled syntax highlighting.

# zsh boots clean
zsh -i -c 'echo OK; exit'
# Expected: OK with no errors.

# vim boots clean
vim -c 'qall' < /dev/null && echo OK
# Expected: OK.

# pi
pi --help | head -5
# Expected: pi CLI help output.
```

- [ ] **Step 5: Final commit (only if any incidental files changed)**

```bash
git status
# If clean, no commit needed.
# If chezmoi added e.g. lazy-lock.json drift, ensure .chezmoiignore covers it.
```

---

## Loop-back items (NOT in this plan)

These were explicitly deferred during brainstorming and remain tracked in the spec:

1. **aichat → pi migration** — pi lacks `aichat -e` execute/revise/copy; revisit later.
2. **Tmux config** — `private_dot_config/tmux/powerline` kept as-is; will design fresh tmux setup separately.
3. **Manual app uninstall** — chatbox, goose, lobehub `.app`s are user-managed.
