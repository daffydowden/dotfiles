function q -d "Ask a general question via pi (multi-turn lite, one-shot pricing)"
    if test (count $argv) -ne 1
        echo "usage: q '<question>'   (quote it — single or double)" >&2
        return 1
    end
    set -l question $argv[1]

    set -l sys_dir ~/.local/share/ai/system-prompts
    set -l sys_prompt ""
    test -r $sys_dir/general-q.md; and set sys_prompt (cat $sys_dir/general-q.md)

    # Models — env-overridable, shared with `ai`
    set -l models openai/gpt-5.4-mini openai/gpt-5.4 anthropic/claude-haiku-4-5 anthropic/claude-sonnet-4-6
    set -q AI_MODELS; and set models (string split ',' -- $AI_MODELS)
    set -l default openai/gpt-5.4-mini
    set -q AI_MODEL; and set default $AI_MODEL
    set -l mi 1
    for i in (seq (count $models))
        if test "$models[$i]" = "$default"
            set mi $i
            break
        end
    end

    set -l convo ""
    set -l answer (__q_ask "$sys_prompt" "$convo" "$question" $models[$mi])

    while true
        if test -z "$answer"
            echo "(no answer returned — try `pi -p --model $models[$mi] hi` to debug)" >&2
            return 1
        end
        echo
        printf '%s\n' "$answer"
        echo
        set_color brblack; echo "  ($models[$mi])"; set_color normal
        read --nchars 1 --prompt-str "[f]ollow-up [m]odel [c]opy [t]alk [q]uit: " choice
        echo
        switch $choice
            case f
                read --prompt-str "follow-up: " followup
                test -z "$followup"; and continue
                set convo "$convo
Q: $question
A: $answer"
                set question $followup
                set answer (__q_ask "$sys_prompt" "$convo" "$question" $models[$mi])
            case m
                if test $mi -lt (count $models)
                    set mi (math $mi + 1)
                    echo "→ retrying with $models[$mi]"
                    set answer (__q_ask "$sys_prompt" "$convo" "$question" $models[$mi])
                else
                    echo "(already at strongest model in cycle)"
                end
            case c
                printf '%s' "$answer" | pbcopy
                echo "copied"
                return
            case t
                pi "Continuing a conversation we started in the terminal:
$convo
Q: $question
A: $answer

Pick up from here."
                return
            case q '*'
                return
        end
    end
end

function __q_ask
    set -l sys $argv[1]
    set -l ctx $argv[2]
    set -l qn $argv[3]
    set -l model $argv[4]
    set -l common --no-tools --no-context-files --no-extensions --no-session
    set -l user_msg "$qn"
    if test -n "$ctx"
        set user_msg "Prior conversation:$ctx

New question: $qn"
    end
    if test -n "$sys"
        pi -p $common --model $model --system-prompt "$sys" "$user_msg" </dev/null 2>/dev/null
    else
        pi -p $common --model $model "$user_msg" </dev/null 2>/dev/null
    end
end
