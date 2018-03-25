# Path to your oh-my-fish.
#set fish_path $HOME/.oh-my-fish

# Theme
#set fish_theme robbyrussell
set fish_theme bobthefish
set -g theme_nerd_fonts yes
set -g theme_color_scheme solarized-dark

set -g default_user richarddowden

# All built-in plugins can be found at ~/.oh-my-fish/plugins/
# Custom plugins may be added to ~/.oh-my-fish/custom/plugins/
# Enable plugins by adding their name separated by a space to the line below.
set fish_plugins theme rbenv brew node tab

alias qlf='qlmanage -p "$argv" > /dev/null ^ /dev/null'
alias lsa='ls -al'

# Path to your custom folder (default path is ~/.oh-my-fish/custom)
#set fish_custom $HOME/dotfiles/oh-my-fish

# colours
set -g TERM "xterm-color"
#set -g TERM "screen-256color"
#set -g TERM "screen-256color-bce"
#set -g  TERM "xterm-256color"
#set -Ux TERM screen-256color-bce

# Add local bin to path
#export N_PREFIX="$HOME/n"; [[ :$PATH: == *":$N_PREFIX/bin:"* ]] || PATH+=":$N_PREFIX/bin"  # Added by n-install (see http://git.io/n-install-repo)
set -gx N_PREFIX "$HOME/n"
set -gx PATH $PATH $N_PREFIX/bin
#set PATH $PATH ~/bin

set -gx GOPATH $HOME/projects
set -gx GOROOT /usr/local/opt/go/libexec
set -gx GOBIN $HOME/projects/bin
set -gx PATH $PATH $GOPATH/bin
set -gx PATH $PATH $GOROOT/bin

# Load oh-my-fish configuration.
#source . $fish_path/oh-my-fish.fish
