function __ai_oneshot -d "Make a bounded direct model request"
    set -l helper ~/.local/share/ai/ai-one-shot.ts
    if not command -q mise
        echo "ai-one-shot: mise is unavailable" >&2
        return 1
    end
    if not test -x $helper
        echo "ai-one-shot: $helper is unavailable; run chezmoi apply" >&2
        return 1
    end
    mise exec -- bun $helper $argv
end
