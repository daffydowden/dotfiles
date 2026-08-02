function __halp_highlight_dangerous -d "Highlight risky command fragments"
    set -l red (set_color red)
    set -l cyan (set_color cyan)
    set -l highlighted $argv[1]
    for word in rm rmdir dd mkfs fdisk parted gdisk shred truncate wipefs kill killall pkill sudo
        set highlighted (string replace --regex --all "\\b$word\\b" "$red$word$cyan" -- $highlighted)
    end
    for flag in '-rf' '-fr' '-Rf' '-fR' '-rF' '-Fr' '--force' '--hard' '--no-preserve-root' '--force-with-lease'
        set highlighted (string replace --all -- $flag "$red$flag$cyan" $highlighted)
    end
    for shell in sh bash fish zsh ksh
        set highlighted (string replace --regex --all "\\|\\s*$shell\\b" "$red| $shell$cyan" -- $highlighted)
    end
    printf '%s' $highlighted
end
