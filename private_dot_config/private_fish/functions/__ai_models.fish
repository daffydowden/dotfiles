function __ai_models -d "Print the configured AI model cycle"
    set -l models \
        openai-codex/gpt-5.6-terra \
        openai-codex/gpt-5.6-sol \
        anthropic/claude-haiku-4-5 \
        anthropic/claude-sonnet-5

    set -l litellm_models_file ~/.cache/ai/litellm-models.txt
    if test -r $litellm_models_file
        set -l discovered (string match -rv '^\s*$' -- (cat $litellm_models_file))
        test (count $discovered) -gt 0; and set models (string replace -r '^' 'litellm/' -- $discovered)
    end
    set -q AI_MODELS; and set models (string split ',' -- $AI_MODELS)
    printf '%s\n' $models
end
