#!/bin/bash
set -eEo pipefail

export DOTFILES="${DOTFILES:-$HOME/.dotfiles}"

# install packages not shipped by Omarchy
bash "$DOTFILES/omarchy/install.sh"

mkdir -p ~/Engineering/
mkdir -p ~/Downloads/!Torrents/
mkdir -p ~/Pictures/Screenshots/
mkdir -p ~/Videos/ScreenRecordings/
mkdir -p ~/.config/user && touch ~/.config/user/.secrets

 
git config --global user.email simun.strukan@gmail.com
git config --global user.name "Simun Strukan"
 
# install oh-my-zsh 
KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# install powerlevel10k 
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

# install zsh autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"

# install zsh syntax highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"

# link zshrc (back up a pre-existing real file once)
[ -e ~/.zshrc ] && [ ! -L ~/.zshrc ] && mv ~/.zshrc ~/.zshrc.bak
ln -sfn "$DOTFILES/omarchy/zsh/zshrc" ~/.zshrc

# tmux plugin manager
TPM_DIR="$DOTFILES/omarchy/config/tmux/plugins/tpm"
if [ ! -d "$TPM_DIR/.git" ]; then
  rm -rf "$TPM_DIR"   # clears the .gitkeep so clone into a clean dir
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

# --- Resilio Sync setup ------------------------------------------------------
sudo usermod -aG "$(id -gn)" rslsync
sudo usermod -aG rslsync "$USER"
mkdir -p "$HOME/.rslsync"
sudo chmod g+rw "$HOME/.rslsync/"
systemctl --user enable rslsync
systemctl --user start rslsync
