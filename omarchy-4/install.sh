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
  inotify-tools


# --- AUR packages ------------------------------------------------------------
# Note: plex-desktop's PKGBUILD pulls a .deb from Plex that has been flaky;
# if it fails to build, that's an upstream source issue, not the script.
omarchy pkg aur add \
  ferdium-bin \
  notion-app-electron \
  xmind \
  rslsync \
  morgen-bin \
  flat-remix-gtk \
  thunderbird-bin \
  vesktop \
  brave-bin \
  1password-cli \
  1password

# omarchy pkg aur add plex-desktop || echo "⚠ plex-desktop build failed (flaky upstream .deb) — install manually"

# --- Omarchy shell plugins (bar/panel widgets) -------------------------------
PLUGINS_TXT="$(dirname "$(readlink -f "$0")")/plugins.txt"

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

if command -v omarchy-plugin-add >/dev/null && [ -f "$PLUGINS_TXT" ]; then
  while IFS= read -r url; do
    url="${url%%#*}"
    url="$(echo "$url" | xargs)"
    [ -n "$url" ] || continue
    if plugin_installed "$url"; then
      echo "ℹ plugin already present: $url"
      continue
    fi
    omarchy plugin add "$url" --enable --yes || echo "⚠ plugin install failed: $url"
  done <"$PLUGINS_TXT"
else
  echo "⚠ omarchy-plugin-add or plugins.txt not found — skipping shell plugins"
fi

# --- Remove Omarchy default apps I don't use ---------------------------------
# Native packages. omarchy pkg drop == omarchy-pkg-drop -> pacman -Rns.
# Idempotent: it checks `pacman -Q` first and silently skips anything not installed.
omarchy pkg drop \
  kdenlive \
  obsidian \
  signal-desktop \
  typora \
  xournalpp

# Default web app launchers (omarchy-webapp-remove).
# Names must match the shipped .desktop EXACTLY — case and spaces included.
# One call per name: omarchy-webapp-remove joins all its args into a single name.
# Only names Omarchy 4 actually ships are listed (see $OMARCHY_PATH/default/applications).
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
