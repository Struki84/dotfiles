#!/bin/bash
clear

# Exit immediately if a command exits with a non-zero status
set -e

catch_errors() {
  echo -e "\n\e[31m Setup failed!\e[0m"
}

trap catch_errors ERR

export PATH="$HOME/.local/share/dotfiles/bin"
INSTALL=~/.local/share/dotfiles/arch/install

echo -e "\n Starting arch setup..."
sudo pacman -Sy --noconfirm --needed git

# Install init
echo -e "\n Installing yay, build tools and intial configurations.."
source $INSTALL/init.sh

# Install desktop
source $INSTALL/desktop.sh
source $INSTALL/theme.sh

# Install terminal & development tools
source $INSTALL/development.sh
cp ~/.local/share/dotfiles/arch/shell/zsh/zshrc ~/.zshrc
cp ~/.local/share/dotfiles/arch/shell/zsh/setup.zsh ~/.oh-my-zsh/custom/setup.zsh

# Start bluetooth
sudo systemctl enable --now bluetooth.service

# Start Network Manager
sudo systemctl enable --now NetworkManager

# Setup git user
git config --global user.email simun.strukan@gmail.com
git config --global user.name Simun Strukan
