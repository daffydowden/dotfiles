#!/bin/bash
set -e

echo "==> Bootstrapping macOS environment"

# Xcode Command Line Tools
if ! xcode-select -p &>/dev/null; then
  echo "==> Installing Xcode Command Line Tools..."
  xcode-select --install
  echo "    Waiting for installation to complete..."
  until xcode-select -p &>/dev/null; do
    sleep 5
  done
fi

# Homebrew
if ! command -v brew &>/dev/null; then
  echo "==> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Keeper CLI (needed for secrets during chezmoi init on work machines)
if ! command -v keeper &>/dev/null; then
  echo "==> Installing Keeper CLI..."
  brew install keeper-commander
fi

# chezmoi
if ! command -v chezmoi &>/dev/null; then
  echo "==> Installing chezmoi..."
  brew install chezmoi
fi

echo "==> Applying dotfiles..."
chezmoi init --apply daffydowden/dotfiles

echo "==> Done!"
