#!/bin/bash
set -eEo pipefail

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
THEME="Flat-Remix-GTK-Blue-Darkest"
SRC="$DOTFILES/omarchy/config/gtk/$THEME"

[ -d "$SRC" ] || { echo "✗ theme not found at $SRC"; exit 1; }

link() {
  local src=$1 dest=$2
  [ -e "$dest" ] && [ ! -L "$dest" ] && mv "$dest" "$dest.bak"
  rm -rf "$dest"
  ln -s "$src" "$dest"
}

# 1. discoverable by name (GTK3 + theme lookups)
mkdir -p ~/.local/share/themes
link "$SRC" ~/.local/share/themes/"$THEME"

# 2. libadwaita override -> ~/.config/gtk-4.0  (Nautilus, Disks, Settings)
mkdir -p ~/.config/gtk-4.0
for item in "$SRC"/libadwaita/*; do
  [ -e "$item" ] || continue
  link "$item" ~/.config/gtk-4.0/"$(basename "$item")"
done

# 3. GTK3 apps + dark mode
gsettings set org.gnome.desktop.interface gtk-theme "$THEME"
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

echo "✓ $THEME applied — relaunch Nautilus to see GTK4 changes"
