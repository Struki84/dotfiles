#!/bin/bash
set -eEo pipefail

export DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
CFG="$DOTFILES/omarchy/config"

# safe symlink: back up an existing real file/dir once, then link
# make sure to create a destination if doesn't exist
link() {
  local src=$1 dest=$2
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    mv "$dest" "$dest.bak"
  fi
  rm -rf "$dest"
  ln -s "$src" "$dest"
}

# CREATE DIRECTORIES -------------------------------------------------------------
echo "Creating user directories..."

mkdir -p ~/Engineering/
mkdir -p ~/Downloads/!Torrents/
mkdir -p ~/Pictures/Screenshots/
mkdir -p ~/Videos/ScreenRecordings/
mkdir -p ~/.config/user && touch ~/.config/user/.secrets

echo "done!"

# MANAGE PACKAGES -------------------------------------------------------------
echo "Install packages not shipped by Omarchy and removed unsed Omarchy packages..."

bash "$DOTFILES/omarchy/install.sh" || echo "⚠ install.sh: some packages failed — continuing with config"

# ZSH INSTALLATION AND SETUP -------------------------------------------------------------

# Install oh-my-zsh
[ -d "$HOME/.oh-my-zsh" ] || \
  KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Install plugins: p10k, zsh-autosuggestions, zsh-syntax-highlighting
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" 2>/dev/null || true
git clone https://github.com/zsh-users/zsh-autosuggestions \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" 2>/dev/null || true
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" 2>/dev/null || true

# Setup user .zshrc
link "$DOTFILES/omarchy/zsh/zshrc" ~/.zshrc

# APP CONFIGS -------------------------------------------------------------
mkdir -p ~/.config/omarchy/hooks/theme-set.d

# RADIOTRAY
link "$CFG/radiotray-ng" ~/.config/radiotray-ng

# ALACRITTY
link "$CFG/alacritty/alacritty.toml" ~/.config/alacritty/alacritty.toml

# VESKTOP (discord client)
link "$CFG/omarchy/config/vesktop/themes" ~/.config/vesktop/themes/

# MAKO (notifications)
link "$CFG/omarchy/config/mako" ~/.config/mako/

# RSLSYNC
link "$CFG/rslsync" ~/.config/rslsync

if id rslsync &>/dev/null; then
  sudo usermod -aG "$(id -gn)" rslsync || true
  sudo usermod -aG rslsync "$USER" || true
  mkdir -p "$HOME/.rslsync"
  sudo chmod g+rw "$HOME/.rslsync/" || true
  if systemctl --user list-unit-files 2>/dev/null | grep -q '^rslsync\.service'; then
    systemctl --user enable --now rslsync || true
  else
    echo "ℹ rslsync has no --user unit; skipping user service (check 'systemctl status rslsync' for a system unit)"
  fi
else
  echo "⚠ rslsync user not found — package likely didn't install; skipping Resilio setup"
fi

# NVIM
link "$CFG/nvim" ~/.config/nvim
link "$CFG/omarchy/hooks/theme-set.d/nvim-user.sh" \
  ~/.config/omarchy/hooks/theme-set.d/nvim-user.sh

# TMUX
link "$CFG/tmux/user.conf" ~/.config/tmux/user.conf
BRIDGE="source-file ~/.config/tmux/user.conf"
grep -qxF "$BRIDGE" ~/.config/tmux/tmux.conf 2>/dev/null \
  || echo "$BRIDGE" >> ~/.config/tmux/tmux.conf

link "$CFG/omarchy/hooks/theme-set.d/tmux-user.sh" \
  ~/.config/omarchy/hooks/theme-set.d/tmux-user.sh

# tpm + plugins
TPM_DIR=~/.config/tmux/plugins/tpm
[ -d "$TPM_DIR/.git" ] || { rm -rf "$TPM_DIR"; git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"; }
tmux new-session -d -s __tpm_install 2>/dev/null || true
"$TPM_DIR/bin/install_plugins" || true
tmux kill-session -t __tpm_install 2>/dev/null || true

# HYPRLAND
link "$CFG/hypr/user.conf" ~/.config/hypr/user.conf
HYPR_BRIDGE="source = ~/.config/hypr/user.conf"
grep -qxF "$HYPR_BRIDGE" ~/.config/hypr/hyprland.conf 2>/dev/null \
  || echo "$HYPR_BRIDGE" >> ~/.config/hypr/hyprland.conf

UWSM_ENV="$HOME/.config/uwsm/env"
touch "$UWSM_ENV"
grep -qxF 'export DOTFILES_PATH=$HOME/.dotfiles/omarchy' "$UWSM_ENV" \
  || cat >> "$UWSM_ENV" <<'EOF'

# My dotfiles bins
export DOTFILES_PATH=$HOME/.dotfiles/omarchy
export PATH=$DOTFILES_PATH/bin:$HOME/.local/bin:$PATH
EOF



# WIP -------------------------------------------------------------


# Setup the gtk theme
# gsettings set org.gnome.desktop.interface gtk-theme 'Flat-Remix-GTK-Blue-Darkest'
# gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

# --- Git identity ------------------------------------------------------------
git config --global user.email simun.strukan@gmail.com
git config --global user.name "Simun Strukan"

mkdir -p ~/.local/share/applications/hidden/
cp $DOTFILES/omarchy/applications/hidden/rtng-bookmark-editor.desktop ~/.local/share/applications/hidden/
cp $DOTFILES/omarchy/applications/hidden/winetricks.desktop ~/.local/share/applications/hidden/

update-desktop-database ~/.local/share/applications

mkdir -p ~/.config/walker/themes/user/

link ~/.local/share/omarchy/default/walker/themes/omarchy-default/layout.xml ~/.config/walker/themes/user/layout.xml
link $CFG/walker/style.css ~/.config/walker/themes/user/style.css

mkdir -p ~/.local/share/icons
tar -xzf $DOTFILES/icons/Vivid-Glassy-Dark.tar.gz -C ~/.local/share/icons/
gsettings set org.gnome.desktop.interface icon-theme "Vivid-Glassy-Dark-Icons"
