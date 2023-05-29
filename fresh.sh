#!/usr/bin/env bash

echo -e "Ready..."
echo -e "May as well ask for sudo upfront"
sudo -v

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
echo "Checking for homebrew..."
if test ! $(which brew); then
  echo "Installing homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/richard.dowden/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Update homebrew recipes
echo "Updating homebrew..."
brew update

#------------------------------------------------------------------------------

echo -e "\n\nhomebrew-bundle\n"

brew tap Homebrew/bundle

echo -e "\n\nhomebrew-mas-cli\n"

brew install mas

#------------------------------------------------------------------------------

echo -e "\n\nfonts\n"
brew bundle -v --file=brewfiles/fonts

echo -e "\n\nutilities\n"
brew bundle -v --file=brewfiles/utilities

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
    read -p "\n\nInstall dotfiles using dotbot?" yn
    case $yn in
        [Yy]* ) 
          echo -e "\nInstalling dotfiles using dotbot\n"
          ./install
          break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

# Download and Install oh-my-fish dotfiles
while true; do
    read -p "\n\nInstall oh-my-fish?" yn
    case $yn in
        [Yy]* ) 
          echo -e "\nInstalling oh-my-fish"
          curl -L http://get.oh-my.fish > install.fish
          fish install.fish --noninteractive --yes
          sudo sh -c 'echo /usr/local/bin/fish >> /etc/shells'
          chsh -s /usr/local/bin/fish
          break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

# Change Mac OS Settings
echo -e "Configure Mac OSX Settings"
brew install mackup
while true; do
    read -p "Change Mac OSX Settings?" yn
    case $yn in
        [Yy]* ) 
          # Write settings from Osx config
          ./macOS.conf
          break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

# Install mackup to restore app settings
echo -e "\n\nInstalling mackup to restore app configs\n"
brew install mackup
while true; do
    read -p "\nSync application settings from icloud using mackup?" yn
    case $yn in
        [Yy]* ) 
          # Restore config from icloud
          mackup restore
          break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

