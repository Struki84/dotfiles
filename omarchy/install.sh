#!/bin/bash
set -eEo pipefail

# Personal Omarchy install script — only apps NOT shipped by Omarchy.
# omarchy pkg add      -> official + OPR repos (pacman)
# omarchy pkg aur add  -> AUR (yay)

# --- Official / OPR packages -------------------------------------------------
omarchy pkg add \
  remmina \
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
  thunderbird-bin

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
omarchy webapp remove \
  "Basecamp" \
  "ChatGPT" \
  "Discord" \
  "Fizzy" \
  "Google Contacts" \
  "Google Messages" \
  "Google Photos" \
  "HEY" \
  "WhatsApp" \
  "X" \
  "YouTube" \
  "Zoom" \ 
  "Github"
