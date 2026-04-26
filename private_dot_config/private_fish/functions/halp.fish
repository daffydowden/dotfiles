function halp -d "Env-aware shell command suggester (pi-backed, aichat -e replacement). Alias: h"
    if test (count $argv) -ne 1
        echo "usage: halp '<description>'   (quote the task — single or double)" >&2
        return 1
    end
    set -l task $argv[1]

    set -l sys_dir ~/.local/share/ai/system-prompts
    set -l env_file ~/.cache/ai/env.txt
    set -l builder ~/.local/share/ai/build-env.sh
    set -l ai_root ~/.local/share/ai
    set -l hist_file $ai_root/history.jsonl
    set -l sess_dir $ai_root/sessions
    mkdir -p $sess_dir

    # Self-heal env cache: rebuild if missing, or if any tracked tool has been
    # upgraded since the snapshot (e.g. via `brew upgrade` outside chezmoi).
    if test -x $builder
        if not test -r $env_file
            $builder
        else
            for t in eza fd rg bat jq delta gh
                set -l p (command -v $t 2>/dev/null)
                if test -n "$p"; and test "$p" -nt "$env_file"
                    $builder
                    break
                end
            end
        end
    end

    # Models — env-overridable
    set -l models openai/gpt-5.4-nano openai/gpt-5.4-mini openai/gpt-5.4 anthropic/claude-haiku-4-5 anthropic/claude-sonnet-4-6
    if set -q AI_MODELS
        set models (string split ',' -- $AI_MODELS)
    end
    set -l default openai/gpt-5.4-mini
    set -q AI_MODEL; and set default $AI_MODEL
    set -l mi 1
    for i in (seq (count $models))
        if test "$models[$i]" = "$default"
            set mi $i
            break
        end
    end

    # System prompt = strict rules + cached env + dynamic context
    set -l rules ""
    test -r $sys_dir/shell-suggester.md; and set rules (cat $sys_dir/shell-suggester.md)
    set -l envctx ""
    test -r $env_file; and set envctx (cat $env_file)
    set -l dyn "PWD: $PWD"
    if git rev-parse --git-dir &>/dev/null
        set -l branch (git branch --show-current 2>/dev/null)
        set -l dirty (git status --porcelain 2>/dev/null | count | string trim)
        set dyn "$dyn
GIT: branch=$branch dirty=$dirty"
    end
    # Failure-aware learning: surface the last 3 deduplicated failures so the
    # model doesn't repeat patterns that errored on this machine.
    # NOTE: jq's `//` treats false as nullish, so use explicit `== false`.
    set -l fail_block ""
    if test -r $hist_file; and command -q jq
        set -l recents (jq -r '
            select(.outcome=="e" and .ok == false) |
            "- task=\"\(.task)\"\n  cmd=\(.cmd)\n  error: \((.error // "") | .[0:200])"
        ' $hist_file 2>/dev/null | awk '!seen[$0]++' | tail -9)
        if test -n "$recents"
            set fail_block "

# RECENT FAILURES (do not repeat these patterns — they errored on this machine):
$recents"
        end
    end

    set -l sys_prompt "$rules

# ENVIRONMENT
$envctx

# CURRENT CONTEXT
$dyn$fail_block"

    set -l session "ai-shell-"(date +%s)
    set -l common --no-tools --no-context-files --no-extensions --no-session

    set -l cmd (pi -p $common --model $models[$mi] \
        --system-prompt "$sys_prompt" "$task" </dev/null 2>/dev/null \
        | string replace -ra '^```[a-z]*\n?|\n?```\s*$' '' | string trim)

    while true
        if test -z "$cmd"
            echo "(no command returned — try `pi -p --model $models[$mi] hi` to debug)" >&2
            return 1
        end
        echo
        set_color cyan; echo "> $cmd"
        set_color brblack; echo "  ($models[$mi])"; set_color normal
        read --nchars 1 --prompt-str "[e]xec [r]evise [m]odel [d]escribe [c]opy [t]alk [q]uit: " choice
        echo
        switch $choice
            case e ''
                # Run via tee so we can both display output and capture it for
                # failure-recall on the next call.
                set -l outlog (mktemp -t ai-out.XXXXXX)
                eval "$cmd" 2>&1 | tee $outlog
                set -l rc $pipestatus[1]
                set -l err ""
                test $rc -ne 0; and set err (head -c 600 $outlog)
                rm -f $outlog
                __ai_log "$task" "$cmd" $models[$mi] e $session $rc "$err"
                return $rc
            case r
                read --prompt-str "revision: " rev
                test -z "$rev"; and continue
                set cmd (pi -p $common --model $models[$mi] \
                    --system-prompt "$sys_prompt" "Original task: $task

Current candidate:
$cmd

Revise per: $rev

Output ONLY the revised command." </dev/null 2>/dev/null \
                    | string replace -ra '^```[a-z]*\n?|\n?```\s*$' '' | string trim)
            case m
                if test $mi -lt (count $models)
                    set mi (math $mi + 1)
                    echo "→ retrying with $models[$mi]"
                    set cmd (pi -p $common --model $models[$mi] \
                        --system-prompt "$sys_prompt" "$task" </dev/null 2>/dev/null \
                        | string replace -ra '^```[a-z]*\n?|\n?```\s*$' '' | string trim)
                else
                    echo "(already at strongest model in cycle)"
                end
            case d
                set -l dprompt (cat $sys_dir/shell-describe.md 2>/dev/null; or echo "Explain in 2-3 short lines.")
                pi -p --no-tools --no-context-files --no-extensions --no-session \
                    --model $models[$mi] --system-prompt "$dprompt" "$cmd" </dev/null
            case c
                printf '%s' "$cmd" | pbcopy
                echo "copied"
                __ai_log "$task" "$cmd" $models[$mi] c $session
                return
            case t
                __ai_log "$task" "$cmd" $models[$mi] t $session
                pi "Working on: $task

Candidate command:
$cmd

Let's discuss."
                return
            case q '*'
                __ai_log "$task" "$cmd" $models[$mi] q $session
                return
        end
    end
end

function __ai_log
    set -l task $argv[1]
    set -l cmd $argv[2]
    set -l model $argv[3]
    set -l outcome $argv[4]
    set -l session $argv[5]
    set -l rc $argv[6]
    set -l error $argv[7]
    set -l hist ~/.local/share/ai/history.jsonl
    if not command -q jq
        return 0
    end
    set -l ok true
    test -n "$rc"; and test $rc -ne 0; and set ok false
    set -l rc_arg
    test -n "$rc"; and set rc_arg --argjson rc $rc
    jq -cn \
        --arg ts (date -u +%Y-%m-%dT%H:%M:%SZ) \
        --arg cwd (pwd) \
        --arg task "$task" \
        --arg cmd "$cmd" \
        --arg model "$model" \
        --arg outcome "$outcome" \
        --arg session "$session" \
        --argjson ok $ok \
        --arg error "$error" \
        '{ts:$ts, cwd:$cwd, task:$task, cmd:$cmd, model:$model, outcome:$outcome, session:$session, ok:$ok, error:$error}' \
        >> $hist
end
