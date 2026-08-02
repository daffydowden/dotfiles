function q -d "Ask a general question directly, with optional Pi handoff"
    if test (count $argv) -ne 1
        echo "usage: q '<question>'   (quote it — single or double)" >&2
        return 1
    end
    set -l question $argv[1]

    set -l sys_dir ~/.local/share/ai/system-prompts
    set -l sys_prompt ""
    test -r $sys_dir/general-q.md; and set sys_prompt (cat $sys_dir/general-q.md)

    set -l models (__ai_models)
    set -l default gpt-5.6-terra
    set -q AI_MODEL; and set default $AI_MODEL
    set -l mi 1
    for i in (seq (count $models))
        if string match -q -- "*$default" $models[$i]
            set mi $i
            break
        end
    end
    __ensure_ai_secret_for_model $models[$mi]; or return

    set -l convo ""
    set -l history_args
    set -l answer (__q_ask "$sys_prompt" $models[$mi] "$question" $history_args)

    while true
        if test -z "$answer"
            echo "(no answer returned — check the model credential and try again)" >&2
            return 1
        end
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
                set -a history_args --message user "$question" --message assistant "$answer"
                set question $followup
                set answer (__q_ask "$sys_prompt" $models[$mi] "$question" $history_args)
            case m
                if test $mi -lt (count $models)
                    set mi (math $mi + 1)
                    __ensure_ai_secret_for_model $models[$mi]; or return
                    echo "→ retrying with $models[$mi]"
                    set answer (__q_ask "$sys_prompt" $models[$mi] "$question" $history_args)
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
    set -l model $argv[2]
    set -l qn $argv[3]
    set -e argv[1..3]
    set -l request_args --preview --model $model --max-tokens 384
    if test -n "$sys"
        set -a request_args --system-prompt "$sys"
    end
    set -a request_args $argv -- "$qn"
    __ai_oneshot $request_args </dev/null
end
