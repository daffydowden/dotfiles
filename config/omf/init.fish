# Path to your oh-my-fish.
#set fish_path $HOME/.oh-my-fish

set -g fish_emoji_width 2

# Theme - https://github.com/oh-my-fish/theme-bobthefish
set fish_theme bobthefish
set -g theme_nerd_fonts yes
#set -g theme_color_scheme terminal2-dark
set -g theme_color_scheme default

set -g theme_display_ruby no
set -g theme_display_k8s_context yes
set -g theme_display_k8s_namespace yes

set -g default_user $USER
# set -g default_user richarddowden #old way

# All built-in plugins can be found at ~/.oh-my-fish/plugins/
# Custom plugins may be added to ~/.oh-my-fish/custom/plugins/
# Enable plugins by adding their name separated by a space to the line below.
set fish_plugins theme asdf brew tab

# asdf node bullshitery
#set -xU GNUPGHOME="${ASDF_DIR:-$HOME/.asdf}/keyrings/nodejs"

alias qlf='qlmanage -p "$argv" > /dev/null ^ /dev/null'
alias lsa='exa --long --header --icons --git -a'

# Path to your custom folder (default path is ~/.oh-my-fish/custom)
#set fish_custom $HOME/dotfiles/oh-my-fish

# Nix
if test -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish'
    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish'
end
# End Nix

# Add local bin to path
#set -gx GOPATH $HOME/projects
#set -gx GOROOT /usr/local/opt/go/libexec
#set -gx GOBIN $HOME/projects/bin
#set -gx PATH $PATH $GOPATH/bin
#set -gx PATH $PATH $GOROOT/bin
set -gx PATH $PATH /opt/homebrew/sbin

# Created by `pipx` on 2023-05-17 17:16:06
set PATH $PATH /Users/richard.dowden/.local/bin

set -gx PATH $PATH $HOME/.krew/bin

# Load oh-my-fish configuration.
#source . $fish_path/oh-my-fish.fish
