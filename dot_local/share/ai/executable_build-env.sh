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

# LiteLLM chat-model discovery (work machines only) — best effort. Curated
# tiers (nano/mini/full + haiku/sonnet) mirror halp's model-cycling order.
# Each tier picks the highest-version live chat model matching its pattern —
# not a hardcoded preferred name — so halp tracks new releases (e.g. a bare
# "gpt-5.5" superseding "gpt-5.4") without going stale, while tiers with no
# newer release yet (e.g. no "gpt-5.5-nano") correctly stay put.
litellm_models=""
litellm_models_file="$HOME/.cache/ai/litellm-models.txt"
pi_models_file="$HOME/.pi/agent/models.json"
if [ -n "$LITELLM_BASE_URL" ] && [ -n "$LITE_LLM_API_KEY" ] && command -v jq >/dev/null 2>&1; then
    model_info=$(curl -fsS --max-time 10 \
        -H "Authorization: Bearer $LITE_LLM_API_KEY" \
        "$LITELLM_BASE_URL/model/info" 2>/dev/null)
    if [ -n "$model_info" ]; then
        chat_ids=$(printf '%s' "$model_info" | jq -r '
            .data[]
            | select(.model_info.mode == "chat")
            | .model_name
            | select(test("^rvu-default") | not)
            | select(test("^eu\\.|^us\\.") | not)
            | select(test("-1m$") | not)
            | select(test("[0-9]{8}") | not)
            | select(test("-codex") | not)
        ')

        pick_tier() {
            # $1 = regex with named (?<major>) and optional (?<minor>) capture
            # groups — prints the id with the highest major/minor among
            # matches, or nothing if none match.
            printf '%s\n' "$chat_ids" | jq -R -s -r --arg re "$1" '
                split("\n") | map(select(length > 0))
                | map(select(test($re)))
                | map({id: ., c: capture($re)})
                | map({id, major: (.c.major | tonumber), minor: (if .c.minor == null then 0 else (.c.minor | tonumber) end)})
                | max_by(.major * 1000 + .minor)
                | if . == null then "" else .id end
            '
        }

        for re in \
            '^gpt-(?<major>[0-9]+)(?:\.(?<minor>[0-9]+))?-nano$' \
            '^gpt-(?<major>[0-9]+)(?:\.(?<minor>[0-9]+))?-mini$' \
            '^gpt-(?<major>[0-9]+)(?:\.(?<minor>[0-9]+))?$' \
            '^claude-haiku-(?<major>[0-9]+)(?:-(?<minor>[0-9]+))?$' \
            '^claude-sonnet-(?<major>[0-9]+)(?:-(?<minor>[0-9]+))?$'; do
            picked=$(pick_tier "$re")
            if [ -n "$picked" ]; then
                litellm_models="$litellm_models$picked
"
            fi
        done
        litellm_models=$(printf '%s' "$litellm_models" | awk 'NF' | sort -u)

        mkdir -p "$(dirname "$litellm_models_file")"
        if [ -n "$litellm_models" ]; then
            printf '%s\n' "$litellm_models" > "$litellm_models_file"

            mkdir -p "$(dirname "$pi_models_file")"
            existing="{}"
            [ -r "$pi_models_file" ] && existing=$(cat "$pi_models_file")
            selected_json=$(printf '%s\n' "$litellm_models" | jq -R -s 'split("\n") | map(select(length > 0))')
            # Carry real context/output limits and pricing from /model/info —
            # without these pi falls back to generic defaults (128K/16.4K)
            # that understate what these models actually support.
            models_json=$(printf '%s' "$model_info" | jq --argjson selected "$selected_json" '
                [ .data[]
                  | select(.model_name as $n | $selected | index($n))
                  | . as $m
                  | {id: .model_name}
                  + (if $m.model_info.max_input_tokens then {contextWindow: $m.model_info.max_input_tokens} else {} end)
                  + (if $m.model_info.max_output_tokens then {maxTokens: $m.model_info.max_output_tokens} else {} end)
                  + (if ($m.model_info.input_cost_per_token != null and $m.model_info.output_cost_per_token != null) then
                       {cost: {
                         input: $m.model_info.input_cost_per_token,
                         output: $m.model_info.output_cost_per_token,
                         cacheRead: ($m.model_info.cache_read_input_token_cost // 0),
                         cacheWrite: ($m.model_info.cache_creation_input_token_cost // 0)
                       }}
                     else {} end)
                  + (if $m.model_info.supports_reasoning != null then {reasoning: $m.model_info.supports_reasoning} else {} end)
                  + (if $m.model_info.supports_vision != null then
                       {input: (if $m.model_info.supports_vision then ["text", "image"] else ["text"] end)}
                     else {} end)
                ]
            ')
            printf '%s' "$existing" | jq \
                --arg baseUrl "$LITELLM_BASE_URL" \
                --argjson models "$models_json" \
                '.providers //= {} | .providers.litellm = {baseUrl: $baseUrl, apiKey: "LITE_LLM_API_KEY", api: "openai-completions", models: $models}' \
                > "$pi_models_file.tmp" && mv "$pi_models_file.tmp" "$pi_models_file"
        else
            rm -f "$litellm_models_file"
        fi
    fi
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
        # Backticks are documentation, not expansion.
        # shellcheck disable=SC2016
        printf 'Brew formulas installed (top-level — `brew leaves`):\n%s\n\n' "$formulas"
    fi

    if [ -n "$mise_tools" ]; then
        # Backticks are documentation, not expansion.
        # shellcheck disable=SC2016
        printf 'Active mise runtimes (`mise ls --current`):\n%s\n\n' "$mise_tools"
    fi

    if [ -n "$litellm_models" ]; then
        printf 'LiteLLM chat models available (curated, work only — refreshed every 7d):\n%s\n\n' \
            "$(printf '%s\n' "$litellm_models" | sed 's/^/- litellm\//')"
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
