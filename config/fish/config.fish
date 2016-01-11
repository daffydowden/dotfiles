set -g OMF_PATH $HOME/.local/share/omf
set -g OMF_CUSTOM $HOME/projects/dotfiles/oh-my-fish
set -g OMF_CONFIG $HOME/.config/omf
source $OMF_PATH/init.fish

# Theme
set fish_theme bobthefish

set -g default_user richarddowden

# All built-in plugins can be found at ~/.oh-my-fish/plugins/
# Custom plugins may be added to ~/.oh-my-fish/custom/plugins/
# Enable plugins by adding their name separated by a space to the line below.
# set fish_plugins theme rbenv brew node tab

# Path to your custom folder (default path is ~/.oh-my-fish/custom)
#set fish_custom $HOME/dotfiles/oh-my-fish

# Add local bin to path
set PATH $PATH ~/bin
set PATH $HOME/.rbenv/bin $PATH
set PATH $HOME/.rbenv/shims $PATH

rbenv rehash >/dev/null ^&1
source ~/.rbenv/completions/rbenv.

# Load oh-my-fish configuration.
. $fish_path/oh-my-fish.fish