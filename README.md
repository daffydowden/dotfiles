# dotfiles

## Install via [homebrew](http://brew.sh) first...

- git
- tmux
- vim
- ack

## ZSH

Currently using [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh) for my terminal - though this might change in the future. Install this with their auto script

    curl -L http://install.ohmyz.sh | sh

## RCM

Uses [Thoughtbot's RCM](http://robots.thoughtbot.com/rcm-for-rc-files-in-dotfiles-repos) to manage the dotfiles.

### Installing RCM

    brew tap thoughtbot/formulae
    brew install rcm
    

### Linking to the dotfiles

List the changes that will be made (Check they're sensible)

    lsrc -d ~/projects/dotfiles
  
Make the changes.

    rcup -v -d ~/projects/dotfiles


## VIM

Ensure the Vundle vim plugin is installed by updating this repos submodules.

    git submodule update --init --recursive
    
Run rcup again if needed. 

    rcup -v -d ~/projects/dotfiles
   
Open Vim and update the plugins

    :PluginInstall
    
### VIM for Git commit messages

Because we're using a custom build of Vim, rather than the default OSX build, the Git editor needs to be configured.

    git config --global core.editor /usr/local/bin/vim
    
## Fonts

Ensure the fonts submodule has been downloaded

    git submodule update --init --recursive

Enter the folder and install the fonts

    cd fonts

    ./install.sh


