function __ai_pick_model -d "Prompt for a model and print the selection"
    set -l models $argv[1..-2]
    set -l current $argv[-1]
    set -l picked ""
    if command -q fzf
        set picked (printf '%s\n' $models | fzf --prompt='model> ' --height=~40% --reverse --header="current: $current")
    else
        for i in (seq (count $models))
            set -l marker ' '
            test "$models[$i]" = "$current"; and set marker '*'
            printf ' %s%d) %s\n' $marker $i $models[$i] >&2
        end
        read --prompt-str 'model #: ' num
        if string match -qr '^[0-9]+$' -- $num; and test $num -ge 1 -a $num -le (count $models)
            set picked $models[$num]
        end
    end
    printf '%s' $picked
end
