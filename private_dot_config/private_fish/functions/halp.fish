function halp -d "Env-aware shell command suggester (pi-backed, aichat -e replacement). Alias: h"
    set -l task ""
    set -l debug_mode 0
    set -l describe_mode 0
    set -l describe_target ""
    set -l tldr_mode 0
    set -l tldr_input ""

    switch (count $argv)
        case 0
            set debug_mode 1
            # Walk history skipping leading halp/h invocations
            set -l prev_cmd ""
            for entry in (builtin history | head -n 20)
                if not string match -qr '^(halp|h)(\s|$)' -- $entry
                    set prev_cmd $entry
                    break
                end
            end
            if test -z "$prev_cmd"
                echo "halp: no previous command found in history" >&2
                return 1
            end
            set task $prev_cmd
        case 1
            switch $argv[1]
                case describe
                    echo "usage: halp describe '<command>'" >&2
                    return 1
                case tldr
                    echo "usage: halp tldr '<cmd>'           (overview)" >&2
                    echo "       halp tldr '<cmd: context>'  (targeted)" >&2
                    return 1
                case '*'
                    set task $argv[1]
            end
        case 2
            switch $argv[1]
                case describe
                    set describe_mode 1
                    set describe_target $argv[2]
                case tldr
                    set tldr_mode 1
                    set tldr_input $argv[2]
                case '*'
                    echo "usage: halp                              (debug previous command)" >&2
                    echo "       halp '<description>'              (suggest a command)" >&2
                    echo "       halp describe '<command>'         (explain a command)" >&2
                    echo "       halp tldr '<cmd[: context]>'      (man-page Q&A)" >&2
                    return 1
            end
        case '*'
            if test $argv[1] = tldr
                set tldr_mode 1
                set tldr_input (string join ' ' $argv[2..-1])
            else
                echo "usage: halp                              (debug previous command)" >&2
                echo "       halp '<description>'              (suggest a command)" >&2
                echo "       halp describe '<command>'         (explain a command)" >&2
                echo "       halp tldr cmd [words]             (man-page Q&A)" >&2
                return 1
            end
    end

    set -l sys_dir ~/.local/share/ai/system-prompts
    set -l env_file ~/.cache/ai/env.txt
    set -l builder ~/.local/share/ai/build-env.sh
    set -l ai_root ~/.local/share/ai
    set -l hist_file $ai_root/history.jsonl
    set -l sess_dir $ai_root/sessions
    mkdir -p $sess_dir

    # Models — env-overridable (resolved before describe early-exit so model cycling works)
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

    # Describe mode: explain a pasted command — exits before env cache (no env context needed)
    if test $describe_mode -eq 1
        set -l common --no-tools --no-context-files --no-extensions --no-session
        set -l dprompt (cat $sys_dir/shell-describe.md 2>/dev/null; or echo "Explain what this shell command does in 2-3 concise lines.")
        echo
        printf '%s> %s%s\n' (set_color cyan) (__halp_highlight_dangerous $describe_target) (set_color normal)
        set_color brblack; echo "  ($models[$mi])"; set_color normal
        echo
        set -l description (pi -p $common --model $models[$mi] \
            --system-prompt "$dprompt" "$describe_target" </dev/null 2>/dev/null)
        if test -z "$description"
            echo "(no description returned — try \`pi -p --model $models[$mi] hi\` to debug)" >&2
            return 1
        end
        printf '%s\n' $description
        echo
        read --nchars 1 --prompt-str "[e]xec [c]opy cmd [t]alk [q]uit: " choice
        echo
        switch $choice
            case e
                eval "$describe_target"
            case c
                printf '%s' "$describe_target" | pbcopy
                echo "copied"
            case t
                pi "Explain this shell command in detail:

$describe_target"
        end
        return 0
    end

    # tldr mode: man-page-backed interactive Q&A — exits before env cache
    if test $tldr_mode -eq 1
        set -l common --no-tools --no-context-files --no-extensions --no-session

        # Parse 'cmd' or 'cmd: context'
        set -l tldr_cmd (string replace -r ':.*' '' -- $tldr_input | string trim)
        set -l tldr_ctx (string replace -r '^[^:]*:?\s*' '' -- $tldr_input | string trim)
        set -l words (string split ' ' -- $tldr_cmd)

        # Fetch man page, with compound-command and --help fallbacks
        set -l mantext ""
        set -l mansource ""
        if test (count $words) -eq 1
            set mantext (man -P cat $words[1] 2>/dev/null | col -bx 2>/dev/null)
            test -n "$mantext"; and set mansource "man $tldr_cmd"
        else
            set -l hyphenated (string join '-' $words)
            set mantext (man -P cat $hyphenated 2>/dev/null | col -bx 2>/dev/null)
            if test -n "$mantext"
                set mansource "man $hyphenated"
            else
                set mantext (man -P cat $words[1] 2>/dev/null | col -bx 2>/dev/null)
                test -n "$mantext"; and set mansource "man $words[1]"
            end
        end
        if test -z "$mantext"
            set mantext ($words --help 2>&1)
            test -n "$mantext"; and set mansource "$tldr_cmd --help"
        end

        if test -z "$mantext"
            echo "halp: no man page or --help output found for '$tldr_cmd'" >&2
            return 1
        end

        # Truncate large pages
        set -l truncated 0
        set -l maxchars 10000
        if test (string length -- $mantext) -gt $maxchars
            set mantext (string sub -l $maxchars -- $mantext)
            set truncated 1
        end

        # System prompt embeds the reference — stable across all follow-up turns
        set -l tprompt (cat $sys_dir/shell-tldr.md 2>/dev/null; or echo "Summarise this man page concisely.")
        set -l sys_with_man "$tprompt

# REFERENCE ($mansource):
$mantext"
        if test $truncated -eq 1
            set sys_with_man "$sys_with_man

[Reference truncated at $maxchars chars — invite the user to ask follow-ups for specific sections or flags]"
        end

        set -l cur_q "Give me an overview of $tldr_cmd"
        test -n "$tldr_ctx"; and set cur_q "For $tldr_cmd: $tldr_ctx"

        echo
        set_color brblack
        printf 'source: %s' $mansource
        test $truncated -eq 1; and printf ' (truncated — follow up for details)'
        echo
        set_color normal
        echo

        set -l convo ""
        set -l answer (pi -p $common --model $models[$mi] --system-prompt "$sys_with_man" "$cur_q" </dev/null 2>/dev/null)

        while true
            if test -z "$answer"
                echo "(no answer returned — try \`pi -p --model $models[$mi] hi\` to debug)" >&2
                return 1
            end
            printf '%s\n' $answer
            echo
            set_color brblack; echo "  ($models[$mi])"; set_color normal
            read --nchars 1 --prompt-str "[f]ollow-up [m]odel [c]opy [t]alk [q]uit: " choice
            echo
            switch $choice
                case f
                    read --prompt-str "follow-up: " followup
                    test -z "$followup"; and continue
                    set convo "$convo
Q: $cur_q
A: $answer"
                    set cur_q $followup
                    set -l ctx_msg $cur_q
                    test -n "$convo"; and set ctx_msg "Prior conversation:$convo

New question: $cur_q"
                    set answer (pi -p $common --model $models[$mi] --system-prompt "$sys_with_man" "$ctx_msg" </dev/null 2>/dev/null)
                case m
                    if test $mi -lt (count $models)
                        set mi (math $mi + 1)
                        echo "→ retrying with $models[$mi]"
                        set -l ctx_msg $cur_q
                        test -n "$convo"; and set ctx_msg "Prior conversation:$convo

New question: $cur_q"
                        set answer (pi -p $common --model $models[$mi] --system-prompt "$sys_with_man" "$ctx_msg" </dev/null 2>/dev/null)
                    else
                        echo "(already at strongest model in cycle)"
                    end
                case c
                    printf '%s' "$answer" | pbcopy
                    echo "copied"
                    return 0
                case t
                    set -l talk_ctx "Exploring docs for: $tldr_cmd"
                    test -n "$convo"; and set talk_ctx "$talk_ctx

Conversation so far:$convo
Q: $cur_q
A: $answer"
                    pi "$talk_ctx

Pick up from here."
                    return 0
                case q '*'
                    return 0
            end
        end
    end

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

    # In debug mode, pull the most recent failure entry for the previous command
    set -l debug_err ""
    if test $debug_mode -eq 1; and test -r $hist_file; and command -q jq
        set debug_err (jq -r --arg cmd "$task" \
            'select(.cmd == $cmd and .ok == false) | .error' \
            $hist_file 2>/dev/null | tail -1)
    end

    # System prompt = strict rules + cached env + dynamic context
    set -l rules ""
    if test $debug_mode -eq 1
        test -r $sys_dir/shell-debug.md; and set rules (cat $sys_dir/shell-debug.md)
        # Fall back to suggester rules if no debug prompt exists
        test -z "$rules"; and test -r $sys_dir/shell-suggester.md; and set rules (cat $sys_dir/shell-suggester.md)
    else
        test -r $sys_dir/shell-suggester.md; and set rules (cat $sys_dir/shell-suggester.md)
    end
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

    # Build the user message: debug mode sends structured context; normal mode sends the task
    set -l user_msg "$task"
    if test $debug_mode -eq 1
        set user_msg "Command: $task"
        if test -n "$debug_err"
            set user_msg "$user_msg
Error: $debug_err"
        end
        echo "(previous command: $task)"
    end

    set -l cmd (pi -p $common --model $models[$mi] \
        --system-prompt "$sys_prompt" "$user_msg" </dev/null 2>/dev/null \
        | string replace -ra '^```[a-z]*\n?|\n?```\s*$' '' | string trim)

    # If the model needs clarification it returns "Q: <question>" — answer and retry once
    if string match -q 'Q: *' -- $cmd
        set -l question (string replace 'Q: ' '' -- $cmd)
        echo
        set_color yellow; echo "? $question"; set_color normal
        read --prompt-str "answer: " clarification
        if test -n "$clarification"
            set user_msg "$user_msg
Clarification: $clarification"
            set cmd (pi -p $common --model $models[$mi] \
                --system-prompt "$sys_prompt" "$user_msg" </dev/null 2>/dev/null \
                | string replace -ra '^```[a-z]*\n?|\n?```\s*$' '' | string trim)
        end
    end

    while true
        if test -z "$cmd"
            echo "(no command returned — try `pi -p --model $models[$mi] hi` to debug)" >&2
            return 1
        end
        echo
        printf '%s> %s%s\n' (set_color cyan) (__halp_highlight_dangerous $cmd) (set_color normal)
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
                    --system-prompt "$sys_prompt" "Original task: $user_msg

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
                        --system-prompt "$sys_prompt" "$user_msg" </dev/null 2>/dev/null \
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

function __halp_highlight_dangerous
    set -l r (set_color red)
    set -l c (set_color cyan)
    set -l h $argv[1]

    # Dangerous commands (word-boundary safe — \b prevents matching substrings)
    for w in rm rmdir dd mkfs fdisk parted gdisk shred truncate wipefs kill killall pkill sudo
        set h (string replace --regex --all "\\b$w\\b" "$r$w$c" -- $h)
    end

    # Dangerous flags (literal substring — - is not a word char so \b doesn't help)
    for f in '-rf' '-fr' '-Rf' '-fR' '-rF' '-Fr' '--force' '--hard' '--no-preserve-root' '--force-with-lease'
        set h (string replace --all -- $f "$r$f$c" $h)
    end

    # Pipe to shell
    for s in sh bash fish zsh ksh
        set h (string replace --regex --all "\\|\\s*$s\\b" "$r| $s$c" -- $h)
    end

    printf '%s' $h
end
