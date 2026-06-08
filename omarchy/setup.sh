#!/bin/bash
set -eEo pipefail
 
# ----------------------------------------------------------------------------
# GIT identity
# ----------------------------------------------------------------------------
git config --global user.email simun.strukan@gmail.com
git config --global user.name "Simun Strukan"
 
# ----------------------------------------------------------------------------
# ZSH + oh-my-zsh + p10k  (Omarchy defaults to bash + starship)
# ----------------------------------------------------------------------------
mkdir -p ~/.config/user && touch ~/.config/user/.secrets
 
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
git clone https://github.com/zsh-users/zsh-autosuggestions \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
 
cp ~/.local/share/dotfiles/arch/shell/zsh/zshrc ~/.zshrc
cp ~/.local/share/dotfiles/arch/shell/zsh/setup.zsh ~/.oh-my-zsh/custom/setup.zsh
 
# --- Resilio Sync setup ------------------------------------------------------
sudo usermod -aG "$(id -gn)" rslsync
sudo usermod -aG rslsync "$USER"
mkdir -p "$HOME/.rslsync"
sudo chmod g+rw "$HOME/.rslsync/"
systemctl --user enable rslsync
systemctl --user start rslsync
