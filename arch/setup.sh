#!/bin/bash
clear

# Exit immediately if a command exits with a non-zero status
set -e

catch_errors() {
  echo -e "\n\e[31m Setup failed!\e[0m"
}

trap catch_errors ERR

export PATH="$HOME/.local/share/dotfiles/arch/bin:$PATH"
INSTALL=~/.local/share/dotfiles/arch/install

# Installation setup
echo -e "\n Installing yay, build tools and preforming installation setup..."
source $INSTALL/setup.sh

# Install desktop
echo -e "\n Setting up desktop..."
source $INSTALL/desktop.sh
echo -e "\n Applying desktop theme"
source $INSTALL/theme.sh

# Install terminal & development tools
echo -e "\n Installing development env..."
source $INSTALL/development.sh

# Installing applications
# source $INSTALL/apps.sh

