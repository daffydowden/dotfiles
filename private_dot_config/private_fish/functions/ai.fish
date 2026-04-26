function ai -d "Env-aware shell command suggester (pi-backed, aichat -e replacement)"
    if test (count $argv) -eq 0
        echo "usage: ai <description>" >&2
        return 1
    end
    set -l task (string join ' ' -- $argv)

    set -l sys_dir ~/.local/share/ai/system-prompts
    set -l env_file ~/.cache/ai/env.txt
    set -l ai_root ~/.local/share/ai
    set -l hist_file $ai_root/history.jsonl
    set -l sess_dir $ai_root/sessions
    mkdir -p $sess_dir

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
    set -l sys_prompt "$rules

# ENVIRONMENT
$envctx

# CURRENT CONTEXT
$dyn"

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
                __ai_log "$task" "$cmd" $models[$mi] e $session
                eval $cmd
                return
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
    set -l hist ~/.local/share/ai/history.jsonl
    if not command -q jq
        return 0
    end
    jq -cn \
        --arg ts (date -u +%Y-%m-%dT%H:%M:%SZ) \
        --arg cwd (pwd) \
        --arg task "$task" \
        --arg cmd "$cmd" \
        --arg model "$model" \
        --arg outcome "$outcome" \
        --arg session "$session" \
        '{ts:$ts, cwd:$cwd, task:$task, cmd:$cmd, model:$model, outcome:$outcome, session:$session}' \
        >> $hist
end
