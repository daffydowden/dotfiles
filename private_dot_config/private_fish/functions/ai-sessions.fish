function ai-sessions -d "Browse ai-shell session history (interactive picker)"
    pi --session-dir ~/.local/share/ai/sessions -r $argv
end
