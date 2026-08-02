function __ensure_ai_secret_for_model -d "Load only the credential required by an AI model"
    set -l model $argv[1]
    set -l key

    switch "$model"
        case 'openai-codex/*' 'google-gemini-cli/*' 'github-copilot/*' ''
            return 0
        case 'anthropic/*'
            set key ANTHROPIC_API_KEY
        case 'openai/*'
            set key OPENAI_API_KEY
        case 'openrouter/*'
            set key OPENROUTER_API_KEY
        case 'deepseek/*'
            set key DEEPSEEK_API_KEY
        case 'groq/*'
            set key GROQ_API_KEY
        case 'google/*' 'google-generative-ai/*'
            set key GOOGLE_AI_API_KEY
        case 'litellm/*'
            set key LITE_LLM_API_KEY
        case '*'
            # Unknown and locally configured providers may use their own auth.
            return 0
    end

    if not __load_ai_secrets --quiet "$key"
        echo "pi: $key is unavailable; unlock the configured vault or run load-ai-secrets" >&2
        return 1
    end
end
