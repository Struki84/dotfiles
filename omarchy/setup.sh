#!/bin/bash
set -eEo pipefail

export DOTFILES="${DOTFILES:-$HOME/.dotfiles}"

mkdir -p ~/Engineering/
mkdir -p ~/Downloads/!Torrents/
mkdir -p ~/Pictures/Screenshots/
mkdir -p ~/Videos/ScreenRecordings/
mkdir -p ~/.config/user && touch ~/.config/user/.secrets

 
git config --global user.email simun.strukan@gmail.com
git config --global user.name "Simun Strukan"
 
# install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# install powerlevel10k 
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

# install zsh autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"

# install zsh syntax highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"

git clone https://github.com/tmux-plugins/tpm $DOTFILES/.config/tmux/plugins/tpm

# --- Resilio Sync setup ------------------------------------------------------
sudo usermod -aG "$(id -gn)" rslsync
sudo usermod -aG rslsync "$USER"
mkdir -p "$HOME/.rslsync"
sudo chmod g+rw "$HOME/.rslsync/"
systemctl --user enable rslsync
systemctl --user start rslsync




