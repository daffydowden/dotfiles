#!/usr/bin/env bash
# Claude Code status line script

input=$(cat)

# Colour codes
RED=$'\033[31m'
YELLOW=$'\033[33m'
ORANGE=$'\033[33m'
RESET=$'\033[0m'

# Model (strip claude- prefix)
model=$(echo "$input" | jq -r '.model.id // .model // empty' | sed 's/^claude-//')

# Effort level
effort=$(echo "$input" | jq -r '.effort.level // empty')
effort_part=""
[ -n "$effort" ] && effort_part="${effort}"

# Context used with colour (plain <55%, yellow 55–79%, red 80%+)
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
ctx_part=""
if [ -n "$used_pct" ]; then
    used_int=$(printf '%.0f' "$used_pct")
    if [ "$used_int" -ge 80 ]; then
        ctx_part="${RED}ctx: ${used_int}%${RESET}"
    elif [ "$used_int" -ge 55 ]; then
        ctx_part="${YELLOW}ctx: ${used_int}%${RESET}"
    else
        ctx_part="ctx: ${used_int}%"
    fi
fi

# Rate limits — compute first so overage state is available for cost section
rl_5h=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
rl_7d=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
rl_part=""
in_overage=false
if [ -n "$rl_5h" ] || [ -n "$rl_7d" ]; then
    in_overage=false
    rl_segments=()

    if [ -n "$rl_5h" ]; then
        rl_5h_int=$(printf '%.0f' "$rl_5h")
        [ "$rl_5h_int" -ge 100 ] && in_overage=true
        if [ "$rl_5h_int" -ge 80 ]; then
            rl_5h_str="${RED}${rl_5h_int}%${RESET}"
        elif [ "$rl_5h_int" -ge 50 ]; then
            rl_5h_str="${ORANGE}${rl_5h_int}%${RESET}"
        else
            rl_5h_str="${rl_5h_int}%"
        fi
        # Countdown: show time remaining when usage >= 50%
        countdown_5h=""
        if [ "$rl_5h_int" -ge 50 ]; then
            resets_at=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
            if [ -n "$resets_at" ]; then
                now=$(date +%s)
                secs_left=$(( resets_at - now ))
                if [ "$secs_left" -gt 0 ]; then
                    hrs_left=$(( secs_left / 3600 ))
                    mins_left=$(( (secs_left % 3600) / 60 ))
                    countdown_5h=" (${hrs_left}h$(printf '%02d' "$mins_left")m)"
                fi
            fi
        fi
        rl_segments+=("5h: ${rl_5h_str}${countdown_5h}")
    fi

    if [ -n "$rl_7d" ]; then
        rl_7d_int=$(printf '%.0f' "$rl_7d")
        [ "$rl_7d_int" -ge 100 ] && in_overage=true
        if [ "$rl_7d_int" -ge 80 ]; then
            rl_7d_str="${RED}${rl_7d_int}%${RESET}"
        elif [ "$rl_7d_int" -ge 50 ]; then
            rl_7d_str="${ORANGE}${rl_7d_int}%${RESET}"
        else
            rl_7d_str="${rl_7d_int}%"
        fi
        # Countdown: show time remaining when usage >= 50%
        countdown_7d=""
        if [ "$rl_7d_int" -ge 50 ]; then
            resets_at_7d=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')
            if [ -n "$resets_at_7d" ]; then
                now=$(date +%s)
                secs_left_7d=$(( resets_at_7d - now ))
                if [ "$secs_left_7d" -gt 0 ]; then
                    days_left=$(( secs_left_7d / 86400 ))
                    hrs_left_7d=$(( (secs_left_7d % 86400) / 3600 ))
                    countdown_7d=" (${days_left}d$(printf '%02d' "$hrs_left_7d")h)"
                fi
            fi
        fi
        rl_segments+=("7d: ${rl_7d_str}${countdown_7d}")
    fi

    if [ ${#rl_segments[@]} -gt 0 ]; then
        IFS=" "
        rl_part="${rl_segments[*]}"
        unset IFS
    fi
fi

# Cost (actual from Claude Code, adaptive precision, overage tracking)
cost_part=""
real_cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
if [ -n "$real_cost" ] && [ "$real_cost" != "0" ]; then
    fmt_cost() {
        awk "BEGIN {
            v = $1
            if (v >= 0.10) printf \"%.2f\", v
            else if (v >= 0.01) printf \"%.3f\", v
            else printf \"%.4f\", v
        }"
    }
    cost_fmt=$(fmt_cost "$real_cost")

    baseline_file="/tmp/claude-overage-baseline"

    if $in_overage; then
        baseline=""
        [ -f "$baseline_file" ] && baseline=$(cat "$baseline_file")

        # Reset if baseline is from a previous session (current cost < baseline)
        if [ -n "$baseline" ]; then
            valid=$(awk "BEGIN { print ($real_cost >= $baseline) ? 1 : 0 }")
            [ "$valid" = "0" ] && baseline=""
        fi

        # Set baseline on first overage render
        if [ -z "$baseline" ]; then
            printf '%s' "$real_cost" > "$baseline_file"
            baseline="$real_cost"
        fi

        overage_delta=$(awk "BEGIN { printf \"%.4f\", $real_cost - $baseline }")
        overage_fmt=$(fmt_cost "$overage_delta")
        cost_part="${RED}\$${cost_fmt} +\$${overage_fmt}${RESET}"
    else
        rm -f "$baseline_file"
        cost_part="\$${cost_fmt}"
    fi
fi

# Worktree / branch
worktree_name=$(echo "$input" | jq -r '.worktree.name // empty')
worktree_branch=$(echo "$input" | jq -r '.worktree.branch // empty')
git_worktree=$(echo "$input" | jq -r '.workspace.git_worktree // empty')
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')

# Helper: truncate a branch name to 20 chars, appending … if cut
truncate_branch() {
    local name="$1"
    if [ "${#name}" -gt 20 ]; then
        printf '%s…' "${name:0:20}"
    else
        printf '%s' "$name"
    fi
}

# Helper: dirty indicator (* when staged or unstaged changes exist)
dirty_suffix() {
    local dir="$1"
    if [ -n "$dir" ] && GIT_OPTIONAL_LOCKS=0 git -C "$dir" status --porcelain 2>/dev/null | grep -q .; then
        printf '*'
    fi
}

branch_label=""
wt_label=""

if [ -n "$worktree_name" ]; then
    # Inside a --worktree session: branch comes from worktree.branch
    raw_branch="${worktree_branch}"
    [ -z "$raw_branch" ] && raw_branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null)
    if [ -n "$raw_branch" ]; then
        trunc=$(truncate_branch "$raw_branch")
        dirty=$(dirty_suffix "$cwd")
        branch_label="branch:${trunc}${dirty}"
    fi
    wt_label="wt:${worktree_name}"
elif [ -n "$git_worktree" ]; then
    # workspace.git_worktree is set (linked worktree, no --worktree session)
    raw_branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null)
    if [ -n "$raw_branch" ]; then
        trunc=$(truncate_branch "$raw_branch")
        dirty=$(dirty_suffix "$cwd")
        branch_label="branch:${trunc}${dirty}"
    fi
    wt_label="wt:${git_worktree}"
elif [ -n "$cwd" ]; then
    raw_branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null)
    if [ -n "$raw_branch" ]; then
        trunc=$(truncate_branch "$raw_branch")
        dirty=$(dirty_suffix "$cwd")
        branch_label="branch:${trunc}${dirty}"
    fi
fi

# Assemble cost block: cost and rate limits share one pipe-segment (space-separated)
cost_block=""
if [ -n "$cost_part" ] && [ -n "$rl_part" ]; then
    cost_block="${cost_part} | ${rl_part}"
elif [ -n "$cost_part" ]; then
    cost_block="$cost_part"
elif [ -n "$rl_part" ]; then
    cost_block="$rl_part"
fi

# Assemble
parts=()
[ -n "$model" ] && parts+=("$model")
[ -n "$effort_part" ] && parts+=("$effort_part")
[ -n "$ctx_part" ] && parts+=("$ctx_part")
[ -n "$cost_block" ] && parts+=("$cost_block")
[ -n "$branch_label" ] && parts+=("$branch_label")
[ -n "$wt_label" ] && parts+=("$wt_label")

if [ ${#parts[@]} -gt 0 ]; then
    output="${parts[0]}"
    for part in "${parts[@]:1}"; do
        output="${output} | ${part}"
    done
    printf "%s" "$output"
fi
