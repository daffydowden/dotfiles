#!/usr/bin/env bash

echo -e "\n\nHomebrew\n"

# Install command line tools
xcode-select --install 

# Check for Homebrew,
# Install if we don't have it
if test ! $(which brew); then
  echo "Installing homebrew..."
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Update homebrew recipes
brew update

#------------------------------------------------------------------------------

echo -e "\n\ncoreutils\n"

# Install GNU core utilities (those that come with OS X are outdated)
brew install coreutils

# Install GNU `find`, `locate`, `updatedb`, and `xargs`, g-prefixed
brew install findutils

# Install Bash 4
brew install bash

# Install more recent versions of some OS X tools
brew tap homebrew/dupes
brew install homebrew/dupes/grep

# update the $PATH in your ~/.bash_profile in order to use these tools over their Mac counterparts
$PATH=$(brew --prefix coreutils)/libexec/gnubin:$PATH

binaries=(
  tree
  ack
  git
)

brew cleanup

#------------------------------------------------------------------------------

echo -e "\n\nhomebrew-bundle\n"

cask_args appdir: '/Applications'

brew tap Homebrew/bundle

#------------------------------------------------------------------------------

echo -e "\n\nbrowsers\n"
brew bundle -v --file=brewfiles/browsers

echo -e "\n\nprogramming languages\n"
brew bundle -v --file=brewfiles/languages

echo -e "\n\neditors and general dev\n"
brew bundle -v --file=brewfiles/editors

echo -e "\n\nenvironment and shell\n"
brew bundle -v --file=brewfiles/environment

echo -e "\n\ndatabases\n"
brew bundle -v --file=brewfiles/databases

echo -e "\n\nmisc\n"
brew bundle -v --file=brewfiles/misc

