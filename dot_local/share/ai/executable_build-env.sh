#!/bin/bash
# Builds ~/.cache/ai/env.txt — environment context for the `ai` shell-command
# suggester. Introspects the live system (brew, mise, $SHELL, uname) so the
# output reflects whichever Mac it runs on. Nothing about the dotfile owner
# (versions, formula list, brew prefix, mise tools) is hardcoded.
#
# Best-effort: missing tools are skipped silently. set -e is OFF on purpose.

brew_prefix=$(brew --prefix 2>/dev/null)
[ -z "$brew_prefix" ] && brew_prefix="/opt/homebrew"

export PATH="$brew_prefix/bin:$brew_prefix/sbin:$HOME/bin:$HOME/.local/bin:$PATH"
# Add mise install dirs without requiring `mise activate` (which doesn't fire
# in non-interactive bash). Glob-best-effort; fine if no matches.
for d in "$HOME"/.local/share/mise/installs/*/*/bin; do
    [ -d "$d" ] && PATH="$d:$PATH"
done
export PATH

dest="$HOME/.cache/ai/env.txt"
mkdir -p "$(dirname "$dest")"

os=$(uname -srm 2>/dev/null || echo "macOS (darwin)")
shell_name=$(basename "${SHELL:-fish}")

formulas=""
if command -v brew >/dev/null 2>&1; then
    formulas=$(brew leaves 2>/dev/null | sort -u | paste -sd ',' - | sed 's/,/, /g')
fi

mise_tools=""
if command -v mise >/dev/null 2>&1; then
    mise_tools=$(mise ls --current 2>/dev/null \
        | awk 'NF>=2 {printf "%s %s, ", $1, $2}' \
        | sed 's/, $//')
fi

{
    cat <<EOF
OS: $os
Default shell: $shell_name (the \`ai\` wrapper itself is fish; suggestions should target that)
Editor: ${EDITOR:-vi}
Pager: ${PAGER:-less}
Brew prefix: $brew_prefix

Preferences (universal — apply regardless of what's installed):
- Modern alternatives where present: rg > grep, fd > find, bat > cat,
  eza > ls, delta as git pager.
- Prefer long-form flags when uncertain — they age better than short forms.

EOF

    if [ -n "$formulas" ]; then
        printf 'Brew formulas installed (top-level — `brew leaves`):\n%s\n\n' "$formulas"
    fi

    if [ -n "$mise_tools" ]; then
        printf 'Active mise runtimes (`mise ls --current`):\n%s\n\n' "$mise_tools"
    fi

    if command -v gdate >/dev/null 2>&1; then
        ts=$(gdate -Iseconds)
    else
        ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    fi
    printf 'Installed tool versions (snapshot %s — match flag syntax to these):\n' "$ts"
    for cmd in 'eza --version' 'fd --version' 'rg --version' 'bat --version' \
               'jq --version' 'delta --version' 'gh --version' 'fzf --version' \
               'mise --version' 'pi --version' 'starship --version' \
               'zoxide --version' 'lazygit --version' 'ugrep --version' \
               'claude --version' 'chezmoi --version'; do
        tool=${cmd%% *}
        # 2>&1 because some tools (notably pi) emit --version on stderr.
        out=$($cmd 2>&1 | head -n 1 | sed 's/[[:space:]]*$//')
        [ -z "$out" ] || printf -- '- %s: %s\n' "$tool" "$out"
    done
} > "$dest"
