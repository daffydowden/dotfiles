function load-ai-secrets -d "Refresh AI credentials from the configured vault"
    for key in OPENAI_API_KEY ANTHROPIC_API_KEY DEEPSEEK_API_KEY \
            OPENROUTER_API_KEY GOOGLE_AI_API_KEY GROQ_API_KEY \
            SRC_ACCESS_TOKEN JIRA_TOKEN LITE_LLM_API_KEY
        set -e $key
    end
    __load_ai_secrets
end
