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
  wget

# --- AUR packages ------------------------------------------------------------
# Note: plex-desktop's PKGBUILD pulls a .deb from Plex that has been flaky;
# if it fails to build, that's an upstream source issue, not the script.
omarchy pkg aur add \
  ferdium-bin \
  notion-app-electron \
  xmind \
  radiotray-ng-git \
  rslsync

omarchy pkg aur add plex-desktop || echo "⚠ plex-desktop build failed (flaky upstream .deb) — install manually"

