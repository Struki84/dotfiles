#!/bin/bash
set -eEo pipefail

# Personal Omarchy install script — only apps NOT shipped by Omarchy.
# omarchy pkg add      -> official + OPR repos (pacman)
# omarchy pkg aur add  -> AUR (yay)

# --- Official / OPR packages -------------------------------------------------
omarchy pkg add \
  solaar \
  dbeaver \
  zsh \
  wget \
  inotify-tools \
  || echo "⚠ official packages: some failed — continuing"


# --- AUR packages ------------------------------------------------------------
# Note: plex-desktop's PKGBUILD pulls a .deb from Plex that has been flaky;
# if it fails to build, that's an upstream source issue, not the script.
omarchy pkg aur add \
  ferdium-bin \
  notion-app-electron \
  xmind \
  rslsync \
  flat-remix-gtk \
  thunderbird-bin \
  vesktop \
  brave-bin \
  1password-cli \
  1password \
  alacritty \
  || echo "⚠ AUR packages: some failed — continuing"

# omarchy pkg aur add plex-desktop || echo "⚠ plex-desktop build failed (flaky upstream .deb) — install manually"

# --- Omarchy shell plugins (bar/panel widgets) -------------------------------
PLUGINS_TXT="$(dirname "$(readlink -f "$0")")/plugins.txt"

plugin_id_for_url() {
  local want="${1%/}"; want="${want%.git}"
  local dir have
  for dir in ~/.config/omarchy/plugins/*/; do
    [ -d "$dir/.git" ] || continue
    have="$(git -C "$dir" remote get-url origin 2>/dev/null)" || continue
    have="${have%/}"; have="${have%.git}"
    if [ "$have" = "$want" ]; then basename "$dir"; return 0; fi
  done
  return 1
}

plugin_enabled() {
  omarchy plugin list --json 2>/dev/null |
    jq -e --arg id "$1" 'any(.[]; .id == $id and .enabled)' >/dev/null
}

if command -v omarchy-plugin-add >/dev/null && [ -f "$PLUGINS_TXT" ]; then
  while IFS= read -r url; do
    url="${url%%#*}"
    url="$(echo "$url" | xargs)"
    [ -n "$url" ] || continue
    if id=$(plugin_id_for_url "$url"); then
      echo "plugin present: $id"
    else
      omarchy plugin add "$url" --enable --yes || echo "plugin install failed: $url"
      id=$(plugin_id_for_url "$url") || continue
    fi
    plugin_enabled "$id" || omarchy plugin enable "$id" || echo "plugin enable failed: $id"
  done <"$PLUGINS_TXT"
else
  echo "omarchy-plugin-add or plugins.txt not found — skipping shell plugins"
fi

# --- Remove Omarchy default apps I don't use ---------------------------------
# Native packages. omarchy pkg drop == omarchy-pkg-drop -> pacman -Rns.
# Idempotent: it checks `pacman -Q` first and silently skips anything not installed.
omarchy pkg drop \
  kdenlive \
  obsidian \
  signal-desktop \
  typora \
  xournalpp \
  || echo "⚠ package removal: some failed — continuing"

# Default web app launchers (omarchy-webapp-remove).
# Names must match the shipped .desktop EXACTLY — case and spaces included.
for webapp in \
  "Basecamp" \
  "Discord" \
  "Google Contacts" \
  "Google Messages" \
  "Google Photos" \
  "HEY" \
  "WhatsApp" \
  "X" \
  "YouTube" \
  "Zoom"; do
  OMARCHY_REMOVE_NOTIFY=false omarchy webapp remove "$webapp" || true
done
