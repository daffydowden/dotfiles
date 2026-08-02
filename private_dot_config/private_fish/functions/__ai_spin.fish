function __ai_spin -d "Run a command with a spinner and print its stdout"
    set -l tmp (mktemp -t ai-spin.XXXXXX)
    set -l err (mktemp -t ai-spin-err.XXXXXX)
    $argv >$tmp 2>$err &
    set -l pid $last_pid
    set -l frames ⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏
    set -l i 1
    while kill -0 $pid 2>/dev/null
        printf '\r%s thinking…' $frames[$i] >&2
        set i (math $i % (count $frames) + 1)
        sleep 0.08
    end
    wait $pid 2>/dev/null
    set -l rc $status
    printf '\r\033[K' >&2
    cat $tmp
    if test $rc -ne 0
        cat $err >&2
    end
    rm -f $tmp $err
    return $rc
end
