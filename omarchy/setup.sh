#!/bin/bash
set -eEo pipefail

export DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
CFG="$DOTFILES/omarchy/config"

# safe symlink: back up an existing real file/dir once, then link
link() {
  local src=$1 dest=$2
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    mv "$dest" "$dest.bak"
  fi
  rm -rf "$dest"
  ln -s "$src" "$dest"
}

# install packages not shipped by Omarchy
bash "$DOTFILES/omarchy/install.sh"

# --- Directories -------------------------------------------------------------
mkdir -p ~/Engineering/
mkdir -p ~/Downloads/!Torrents/
mkdir -p ~/Pictures/Screenshots/
mkdir -p ~/Videos/ScreenRecordings/
mkdir -p ~/.config/user && touch ~/.config/user/.secrets

# --- Git identity ------------------------------------------------------------
git config --global user.email simun.strukan@gmail.com
git config --global user.name "Simun Strukan"

# --- zsh: oh-my-zsh + p10k + plugins ------
KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" 2>/dev/null || true
git clone https://github.com/zsh-users/zsh-autosuggestions \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" 2>/dev/null || true
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" 2>/dev/null || true

link "$DOTFILES/omarchy/zsh/zshrc" ~/.zshrc

# --- Config symlinks (repo: config/  ->  home: ~/.config/) -------------------
# Apps Omarchy does NOT manage -> link the whole dir
link "$CFG/nvim"         ~/.config/nvim
link "$CFG/radiotray-ng" ~/.config/radiotray-ng
link "$CFG/rslsync"      ~/.config/rslsync

# Alacritty: own our toml (re-imports the Omarchy theme + launches zsh)
mkdir -p ~/.config/alacritty
link "$CFG/alacritty/alacritty.toml" ~/.config/alacritty/alacritty.toml

# --- tmux: keep Omarchy's themed base, layer personal user.conf --------------
mkdir -p ~/.config/tmux
link "$CFG/tmux/user.conf" ~/.config/tmux/user.conf
BRIDGE="source-file ~/.config/tmux/user.conf"
grep -qxF "$BRIDGE" ~/.config/tmux/tmux.conf 2>/dev/null \
  || echo "$BRIDGE" >> ~/.config/tmux/tmux.conf

# theme-set hook: self-heals the bridge + reloads live tmux on theme change
mkdir -p ~/.config/omarchy/hooks/theme-set.d

link "$CFG/omarchy/hooks/theme-set.d/tmux-user.sh" \
  ~/.config/omarchy/hooks/theme-set.d/tmux-user.sh

link "$CFG/omarchy/hooks/theme-set.d/nvim-user.sh" \
  ~/.config/omarchy/hooks/theme-set.d/nvim-user.sh

# --- hypr: layer personal user.conf onto Omarchy's config --------------------
link "$CFG/hypr/user.conf" ~/.config/hypr/user.conf
HYPR_BRIDGE="source = ~/.config/hypr/user.conf"
grep -qxF "$HYPR_BRIDGE" ~/.config/hypr/hyprland.conf 2>/dev/null \
  || echo "$HYPR_BRIDGE" >> ~/.config/hypr/hyprland.conf

# tpm + plugins, cloned into the REAL config path (not the repo)
TPM_DIR=~/.config/tmux/plugins/tpm
[ -d "$TPM_DIR/.git" ] || { rm -rf "$TPM_DIR"; git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"; }
"$TPM_DIR/bin/install_plugins" || true

# --- Resilio Sync setup ------------------------------------------------------
sudo usermod -aG "$(id -gn)" rslsync
sudo usermod -aG rslsync "$USER"
mkdir -p "$HOME/.rslsync"
sudo chmod g+rw "$HOME/.rslsync/"
systemctl --user enable rslsync
systemctl --user start rslsync
