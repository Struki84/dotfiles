#!/bin/bash
# Personal Omarchy 4 setup. Idempotent: safe to re-run after pulling dotfiles.
#   ./setup.sh            normal run
#   ./setup.sh --force    also overwrite ~/.config/omarchy/shell.json from the repo
set -eEo pipefail

export DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
OMA="$DOTFILES/omarchy-4"
CFG="$OMA/config"
FORCE=0
[[ ${1:-} == "--force" ]] && FORCE=1

# safe symlink: back up an existing real file/dir once, then link
# make sure to create a destination if doesn't exist
link() {
  local src=$1 dest=$2
  mkdir -p "$(dirname "$dest")"
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    mv "$dest" "$dest.bak"
  fi
  rm -rf "$dest"
  ln -s "$src" "$dest"
}

# append a line to a file once (idempotent bridge into Omarchy-managed configs)
ensure_line() {
  local line=$1 file=$2
  mkdir -p "$(dirname "$file")"
  grep -qxF "$line" "$file" 2>/dev/null || echo "$line" >>"$file"
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
echo "Install packages not shipped by Omarchy and remove unused Omarchy packages..."

bash "$OMA/install.sh" || echo "⚠ install.sh: some packages failed — continuing with config"

# ZSH INSTALLATION AND SETUP -------------------------------------------------------------

# Install oh-my-zsh
[ -d "$HOME/.oh-my-zsh" ] ||
  KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Install plugins: p10k, zsh-autosuggestions, zsh-syntax-highlighting
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" 2>/dev/null || true
git clone https://github.com/zsh-users/zsh-autosuggestions \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" 2>/dev/null || true
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" 2>/dev/null || true

# Setup user .zshrc
link "$OMA/zsh/zshrc" ~/.zshrc

# PERSONAL BIN SCRIPTS -------------------------------------------------------------
# Omarchy 4 puts ~/.local/bin on the session PATH (Hyprland autostart, terminals,
# launchers), so linking here is what makes e.g. `torrent-sentry` resolvable
# from hypr/user.lua. (~/.config/uwsm/env was retired in v4.)
mkdir -p ~/.local/bin
for script in "$OMA"/bin/*; do
  [ -f "$script" ] || continue
  link "$script" ~/.local/bin/"$(basename "$script")"
done

# APP CONFIGS -------------------------------------------------------------
mkdir -p ~/.config/omarchy/hooks/theme-set.d

# RADIOTRAY
link "$CFG/radiotray-ng" ~/.config/radiotray-ng

# ALACRITTY
link "$CFG/alacritty/alacritty.toml" ~/.config/alacritty/alacritty.toml

# VESKTOP (discord client)
link "$CFG/vesktop/themes" ~/.config/vesktop/themes

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
ensure_line "source-file ~/.config/tmux/user.conf" ~/.config/tmux/tmux.conf

link "$CFG/omarchy/hooks/theme-set.d/tmux-user.sh" \
  ~/.config/omarchy/hooks/theme-set.d/tmux-user.sh

# tpm + plugins
TPM_DIR=~/.config/tmux/plugins/tpm
[ -d "$TPM_DIR/.git" ] || { rm -rf "$TPM_DIR"; git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"; }
tmux new-session -d -s __tpm_install 2>/dev/null || true
"$TPM_DIR/bin/install_plugins" || true
tmux kill-session -t __tpm_install 2>/dev/null || true

# HYPRLAND -------------------------------------------------------------
# Omarchy 4 configures Hyprland in Lua. user.lua is loaded last from
# ~/.config/hypr/hyprland.lua so it overrides Omarchy's defaults.
# NOTE: `omarchy refresh hyprland` rewrites hyprland.lua; re-run this script after.
link "$CFG/hypr/user.lua" ~/.config/hypr/user.lua
ensure_line 'require("hypr.user")' ~/.config/hypr/hyprland.lua

# OMARCHY SHELL (bar, panels, menu) -------------------------------------------------------------

# shell.toml is read-only for the shell -> symlink is safe.
link "$CFG/omarchy/shell.toml" ~/.config/omarchy/shell.toml

# Shell plugins referenced by shell.json. Install before copying shell.json so
# the plugin's own layout edits get replaced by mine. Plugins are git clones in
# ~/.config/omarchy/plugins/<id>/, so match on the git remote, not the dir name.
plugin_installed() {
  local want="${1%/}"; want="${want%.git}"
  local dir have
  for dir in ~/.config/omarchy/plugins/*/; do
    [ -d "$dir/.git" ] || continue
    have="$(git -C "$dir" remote get-url origin 2>/dev/null)" || continue
    have="${have%/}"; have="${have%.git}"
    [ "$have" = "$want" ] && return 0
  done
  return 1
}

if command -v omarchy-plugin-add >/dev/null; then
  while IFS= read -r url; do
    url="${url%%#*}"
    url="$(echo "$url" | xargs)"
    [ -n "$url" ] || continue
    if plugin_installed "$url"; then
      echo "ℹ plugin already present: $url"
      continue
    fi
    omarchy plugin add "$url" --enable --yes || echo "⚠ plugin install failed: $url"
  done <"$OMA/plugins.txt"
else
  echo "⚠ omarchy-plugin-add not found — skipping shell plugins (not Omarchy 4?)"
fi

# shell.json is REWRITTEN by Omarchy (omarchy bar add/move, drag-reorder, plugin
# enable) via mv, which would replace a symlink. Copy it instead; only seed when
# absent so live tweaks survive re-runs. Use --force to overwrite from the repo.
# Push local changes back with: save-dot-shell
if [ ! -s ~/.config/omarchy/shell.json ] || [ "$FORCE" -eq 1 ]; then
  cp -f "$CFG/omarchy/shell.json" ~/.config/omarchy/shell.json
  echo "shell.json copied to ~/.config/omarchy/"
else
  echo "ℹ ~/.config/omarchy/shell.json exists — left as is (use --force to overwrite)"
fi

# WIP -------------------------------------------------------------

# --- Git identity ------------------------------------------------------------
git config --global user.email simun.strukan@gmail.com
git config --global user.name "Simun Strukan"

# --- Hiding unneeded apps from the launcher ---------------------------------
mkdir -p ~/.local/share/applications/hidden/
cp "$OMA/applications/hidden/rtng-bookmark-editor.desktop" ~/.local/share/applications/hidden/
cp "$OMA/applications/hidden/winetricks.desktop" ~/.local/share/applications/hidden/

update-desktop-database ~/.local/share/applications

# --- Styling GTK ui and icons ----------------------------------------------
mkdir -p ~/.local/share/icons
tar -xzf "$OMA/icons/Vivid-Glassy-Dark-Icons.tar.gz" -C ~/.local/share/icons/

# omarchy-theme-set-gnome resets gtk/icon theme on every theme change; the hook
# re-applies mine afterwards. Run it once now too.
link "$CFG/omarchy/hooks/theme-set.d/gtk-user.sh" \
  ~/.config/omarchy/hooks/theme-set.d/gtk-user.sh
bash "$CFG/omarchy/hooks/theme-set.d/gtk-user.sh" || true

# for setting global editor
# echo -e 'EDITOR=nvim\nVISUAL=nvim' | sudo tee -a /etc/environment

# APPLY -------------------------------------------------------------
# No-ops when run from a TTY without a session.
if command -v hyprctl >/dev/null && [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
  hyprctl reload >/dev/null && hyprctl configerrors || true
fi
if command -v omarchy-restart-shell >/dev/null && [ -n "${WAYLAND_DISPLAY:-}" ]; then
  omarchy restart shell || true
fi

echo "Setup complete."
