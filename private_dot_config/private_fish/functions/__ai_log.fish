function __ai_log -d "Append one AI-shell interaction to history"
    command -q jq; or return 0
    set -l task $argv[1]
    set -l cmd $argv[2]
    set -l model $argv[3]
    set -l outcome $argv[4]
    set -l session $argv[5]
    set -l rc $argv[6]
    set -l error $argv[7]
    set -l hist ~/.local/share/ai/history.jsonl
    set -l ok true
    test -n "$rc"; and test $rc -ne 0; and set ok false
    mkdir -p (dirname $hist)
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
        >>$hist
end
