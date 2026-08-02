function __ai_spin -d "Run a command with a spinner and print its stdout"
    set -l tmp (mktemp -t ai-spin.XXXXXX)
    $argv >$tmp 2>/dev/null &
    set -l pid $last_pid
    set -l frames ⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏
    set -l i 1
    while kill -0 $pid 2>/dev/null
        printf '\r%s thinking…' $frames[$i] >&2
        set i (math $i % (count $frames) + 1)
        sleep 0.08
    end
    wait $pid 2>/dev/null
    printf '\r\033[K' >&2
    cat $tmp
    rm -f $tmp
end
