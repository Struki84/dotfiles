#!/bin/bash

clear
sudo pacman -Sy --noconfirm --needed git

echo -e "\n Starting arch setup..."

# Exit immediately if a command exits with a non-zero status
set -e

export PATH="$HOME/.local/share/.dotfiles/bin"
INSTALL=~/.local/share/.dotfiles/arch/install

catch_errors() {
  echo -e "\n\e[31m Setup failed!\e[0m"
}

trap catch_errors ERR

# Install init
echo -e "\n Installing yay, build tools and intial configurations.."
source $INSTALL/init.sh

# Install desktop
source $INSTALL/desktop.sh

# Install terminal & development tools
source $INSTALL/development.sh

