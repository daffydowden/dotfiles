#!/usr/bin/env bash

echo -e "\n\nHomebrew\n"

# Install command line tools
if test ! $(xcode-select -p); then
	echo "You must install xcode tools"
	xcode-select --install 

	# Wait to download and install
	while true; do
			read -p "Has the Xcode command line tools installation completed?" yn
			case $yn in
					[Yy]* ) break;;
					[Nn]* ) exit;;
					* ) echo "Please answer yes or no.";;
			esac
	done
fi

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

brew tap Homebrew/bundle

#------------------------------------------------------------------------------

echo -e "\n\nprogramming languages\n"
brew bundle -v --file=brewfiles/languages

echo -e "\n\neditors and general dev\n"
brew bundle -v --file=brewfiles/editors

echo -e "\n\nenvironment and shell\n"
brew bundle -v --file=brewfiles/environment

echo -e "\n\ndatabases\n"
brew bundle -v --file=brewfiles/databases

echo -e "\n\nbrowsers\n"
brew bundle -v --file=brewfiles/browsers

echo -e "\n\nmisc\n"
brew bundle -v --file=brewfiles/misc

# Install dotfiles
while true; do
    read -p "Install dotfiles using dotbot?" yn
    case $yn in
        [Yy]* ) 
          echo -e "\n\nInstalling dotfiles using dotbot\n"
          ./install
          break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

# Install mackup to restore app settings
while true; do
    read -p "Sync application settings from icloud using mackup?" yn
    case $yn in
        [Yy]* ) 
          echo -e "\n\nInstalling mackup to restore app configs\n"
          brew install mackup
          # Restore config from icloud
          mackup restore
          break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
