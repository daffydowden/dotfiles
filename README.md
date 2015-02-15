# dotfiles

## Install via homebrew first...

- git
- zsh
- tmux
- vim

## RCM

Uses [Thoughtbot's RCM](http://robots.thoughtbot.com/rcm-for-rc-files-in-dotfiles-repos) to manage the dotfiles.

### Installing RCM

    brew tap thoughtbot/formulae
    brew install rcm
    

### Linking to the dotfiles

List the changes that will be made (Check they're sensible)

    lsrc -d ~/projects/dotfiles
  
Make the changes.

    rcup -v -d projects/dotfiles

