# dotfiles

## Installation 

### Prerequistes

- Xcode command line tools
- `xcode-select --install`
- `sudo xcodebuild -license`

### Installation Instructions

- `./fresh.sh`
  - Runs the following:
  - homebrew installation and update 
  - brew bundle 
  - `./install` - in order to sync install dotfiles
  - `mackup restore` - in order to sync application settings from icloud

### Installs 

- [homebrew](http://brew.sh)
- [cask](http://caskroom.io) - `brew install caskroom/cask/brew-cask`
- [Brew Bundle](https://github.com/Homebrew/homebrew-bundle) - `brew tap Homebrew/bundle`
- tmux
- vim
- ack

## Oh-my-fish

 - Install via the [automated install script](https://github.com/fish-shell/oh-my-fish#install)

`curl -L git.io/omf | sh`

- Set to be default shell

`echo "/usr/local/bin/fish" | sudo tee -a /etc/shells`
`chsh -s /usr/local/bin/fish`

## ZSH

To use [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh) for the terminal, install this with their auto script

    curl -L http://install.ohmyz.sh | sh

## Dotbot

Uses [anishathalye's dotbot](https://github.com/anishathalye/dotbot) to manage the dotfiles.

### Linking to the dotfiles

To manually resync the dotfiles

    ./install
  
Which will rerun the config in the `install.conf.yaml` file. This operation should be idempotent.


## VIM

Ensure the Vundle vim plugin is installed by updating this repos submodules.

    git submodule update --init --recursive
    
Open Vim and update the plugins

    :PluginInstall

Or update them from the command line

    vim +PluginInstall +qall
    
### VIM for Git commit messages

Because we're using a custom build of Vim, rather than the default OSX build, the Git editor needs to be configured.

    git config --global core.editor /usr/local/bin/vim
    
## Fonts

Ensure the fonts submodule has been downloaded

    git submodule update --init --recursive

Enter the folder and install the fonts

    cd fonts

    ./install.sh


