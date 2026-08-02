#!/usr/bin/env bash
set -euo pipefail

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
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  else
    printf 'Homebrew installed, but brew could not be located\n' >&2
    exit 1
  fi
fi

read -r -p "Is this a work machine? [y/N] " work_reply
case "$work_reply" in
  y|Y|yes|YES) is_work=true ;;
  *) is_work=false ;;
esac

if [[ "$is_work" == true ]] && ! command -v keeper &>/dev/null; then
  echo "==> Installing Keeper CLI..."
  brew install keeper-commander
  command -v keeper >/dev/null 2>&1 || {
    printf 'Keeper CLI installation did not provide the keeper command\n' >&2
    exit 1
  }
fi

# chezmoi
if ! command -v chezmoi &>/dev/null; then
  echo "==> Installing chezmoi..."
  brew install chezmoi
fi

echo "==> Applying dotfiles..."
chezmoi init --apply --promptBool "Is this a work machine?=$is_work" daffydowden/dotfiles

echo "==> Done!"
