# Path to your oh-my-fish.
#set fish_path $HOME/.oh-my-fish

# Theme
#set fish_theme robbyrussell
set fish_theme bobthefish
set -g theme_nerd_fonts yes
set -g theme_color_scheme terminal2-dark
set -g theme_display_ruby yes

set -g default_user richard.dowden

set -g theme_display_k8s_context yes
set -g theme_display_user ssh
set -g theme_display_hostname ssh


# All built-in plugins can be found at ~/.oh-my-fish/plugins/
# Custom plugins may be added to ~/.oh-my-fish/custom/plugins/
# Enable plugins by adding their name separated by a space to the line below.
set fish_plugins theme brew node tab

source /usr/local/opt/asdf/asdf.fish

alias qlf='qlmanage -p "$argv" > /dev/null ^ /dev/null'
alias lsa='ls -al'

# Path to your custom folder (default path is ~/.oh-my-fish/custom)
#set fish_custom $HOME/dotfiles/oh-my-fish

# colours
#set -g TERM "xterm-color"
#set -g TERM "screen-256color"
#set -g TERM "screen-256color-bce"
#set -g  TERM "xterm-256color"
#set -Ux TERM screen-256color-bce

# Add local bin to path
#export N_PREFIX="$HOME/n"; [[ :$PATH: == *":$N_PREFIX/bin:"* ]] || PATH+=":$N_PREFIX/bin"  # Added by n-install (see http://git.io/n-install-repo)
set -gx N_PREFIX "$HOME/n"
set -gx PATH $PATH $N_PREFIX/bin
#set PATH $PATH ~/bin

set -gx EDITOR nvim

set -gx GOPATH $HOME/projects/go
set -gx GOROOT /usr/local/opt/go/libexec
set -gx GOBIN $HOME/projects/go/bin
set -gx PATH $PATH $GOPATH/bin
set -gx PATH $PATH $GOROOT/bin

# emacs ansi-term support
#if test -n "$EMACS"
  #set -x TERM eterm-color
#end
# this function may be required
function fish_title
  true
end

# Load oh-my-fish configuration.
#source . $fish_path/oh-my-fish.fish
