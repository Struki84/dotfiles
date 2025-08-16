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

# Installation setup
echo -e "\n Installing yay, build tools and preforming installation setup..."
source $INSTALL/setup.sh

# Install desktop
source $INSTALL/desktop.sh
source $INSTALL/theme.sh

# Install terminal & development tools
source $INSTALL/development.sh

# Installing applications
# source $INSTALL/apps.sh

