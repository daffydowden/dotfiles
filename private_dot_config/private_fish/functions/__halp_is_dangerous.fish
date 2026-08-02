function __halp_is_dangerous -d "Return success when a command needs confirmation"
    string match -qr -- \
        '(^|[;&|[:space:]])(rm|rmdir|dd|mkfs|fdisk|parted|gdisk|shred|truncate|wipefs|kill|killall|pkill|sudo)([;&|[:space:]]|$)|--(force|hard|no-preserve-root|force-with-lease)|\|[[:space:]]*(sh|bash|fish|zsh|ksh)([[:space:]]|$)' \
        "$argv[1]"
end
