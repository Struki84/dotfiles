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
  radiotray-ng-git \
  rslsync \
  morgen-bin \
  flat-remix-gtk \
  thunderbird-bin \
  vesktop

omarchy pkg aur add plex-desktop || echo "⚠ plex-desktop build failed (flaky upstream .deb) — install manually"

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
