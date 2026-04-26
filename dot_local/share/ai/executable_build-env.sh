#!/bin/bash
# Builds ~/.cache/ai/env.txt — environment context for the `ai` shell-command
# suggester. Lean: only what the model can't already infer from its own
# parametric memory. The unique signal is (a) which tools the user prefers and
# (b) the *installed versions* of those tools, so the model can match flag
# syntax to the actually-installed reality (eza 0.10 vs 0.21, etc.).
#
# Best-effort: missing tools are skipped silently. set -e is intentionally OFF.

export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$HOME/bin:$HOME/.local/bin:$PATH"
# Add mise-managed install dirs (e.g. pi via npm-mariozechner-pi-coding-agent)
# without requiring `mise activate`, which doesn't fire in non-interactive bash.
for d in "$HOME"/.local/share/mise/installs/*/*/bin; do
    [ -d "$d" ] && PATH="$d:$PATH"
done
export PATH

dest="$HOME/.cache/ai/env.txt"
mkdir -p "$(dirname "$dest")"

cat > "$dest" <<'EOF'
OS: macOS (darwin)
Shell: fish (fallback: zsh)
Editor: nvim
Pager: bat (files), delta (git diffs), less (stdin)

Preferred tools (use these instead of the POSIX defaults the model would
otherwise reach for): rg, fd, bat, eza, delta, jq, gh, mise, zoxide (z),
fzf, lazygit, ugrep (also aliased to `grep`), pi, claude, chezmoi.

Languages installed via mise (-g): node 22, bun, python 3.12, rust,
ruby 3.3.6, java openjdk-21, uv.

EOF

{
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
} >> "$dest"
