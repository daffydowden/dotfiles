# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
#ZSH_THEME="rdowden" # based on robbyrussell 
#ZSH_THEME="powerline"
DEFAULT_USER='Richard'
ZSH_THEME="agnoster"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(autojump git git-flow github bundler heroku osx rails npm textmate vagrant cap brew ip per-directory-history extract tmux)

source $ZSH/oh-my-zsh.sh

######################
# User configuration #
######################

# DYLD_LIBRARY_PATH - For mysql and mysql2 gem
# export DYLD_LIBRARY_PATH="~/Developer/Cellar/mysql/5.5.19/lib:$DYLD_LIBRARY_PATH"

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# AutoJump
if [ -f `brew --prefix`/etc/autojump ]; then
  . `brew --prefix`/etc/autojump
fi

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

# Correct path for homebrew
export PATH=/usr/local/bin:/Users/richarddowden/Library/Python/2.7/bin:$(npm bin):$PATH

alias npm-exec='PATH=$(npm bin):$PATH'

# Powerline config
. ~/Library/Python/2.7/lib/python/site-packages/powerline/bindings/zsh/powerline.zsh
