#!/bin/bash
set -eEo pipefail

# Personal Omarchy install script — only apps NOT shipped by Omarchy.
# omarchy pkg add      -> official + OPR repos (pacman)
# omarchy pkg aur add  -> AUR (yay)

# --- Omarchy shell plugins (one git URL per line) -----------------------------
# Plugin IDs referenced in config/omarchy/shell.json must come from this list.
#   drako.floating-bar + drako.control  <- drako-floating-bar
#   akshar.radio-atlas                  <- omarchy-radio-atlas
PLUGINS=(
  https://github.com/Jster80/drako-floating-bar
  https://github.com/AksharP5/omarchy-radio-atlas.git
  https://github.com/brdweb/omacalendar-widget.git
  https://github.com/huacnlee/omamail.git
)

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
  thunderbird-bin \
  vesktop \
  brave-bin \
  1password-cli \
  1password \
  alacritty \
  || echo "⚠ AUR packages: some failed — continuing"
  # flat-remix-gtk \

omarchy pkg aur add plex-desktop || echo "⚠ plex-desktop build failed (flaky upstream .deb) — install manually"

# --- OmaCalendar app (required by the org.omacalendar.widget plugin) ---------
# Release is verified against SHA256SUMS and GitHub build attestations before
# it's handed to pacman. Needs github-cli, and `gh auth login` done once.
install_omacalendar() {
  local version=1.0.0
  local package="omacalendar-${version}-1-x86_64.pkg.tar.zst"
  local release_url="https://github.com/brdweb/omacalendar/releases/download/v${version}"
  local workdir

  workdir=$(mktemp -d)
  pushd "$workdir" >/dev/null

  curl -fLO "${release_url}/${package}"
  curl -fLO "${release_url}/SHA256SUMS"
  grep " ${package}$" SHA256SUMS | sha256sum --check --strict

  gh attestation verify "$package" --repo brdweb/omacalendar \
    --source-ref "refs/tags/v${version}" \
    --signer-workflow brdweb/omacalendar/.github/workflows/release.yml
  gh attestation verify "$package" --repo brdweb/omacalendar \
    --source-ref "refs/tags/v${version}" \
    --signer-workflow brdweb/omacalendar/.github/workflows/release.yml \
    --predicate-type https://spdx.dev/Document/v2.3

  sudo pacman -U --noconfirm "./${package}"

  popd >/dev/null
  rm -rf "$workdir"

  systemctl --user daemon-reload
  systemctl --user enable --now omacalendard.socket
  systemctl --user try-restart omacalendard.service
  xdg-mime default org.omacalendar.OmaCalendar.desktop x-scheme-handler/omacalendar
}

if pacman -Q omacalendar &>/dev/null; then
  echo "omacalendar present: $(pacman -Q omacalendar)"
elif ! command -v gh >/dev/null; then
  echo "⚠ github-cli not installed — skipping omacalendar (the calendar widget will show no events)"
else
  install_omacalendar || echo "⚠ omacalendar install failed — continuing"
fi

# --- Omarchy shell plugins (bar/panel widgets) -------------------------------
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

if command -v omarchy-plugin-add >/dev/null; then
  for url in "${PLUGINS[@]}"; do
    if id=$(plugin_id_for_url "$url"); then
      echo "plugin present: $id"
    else
      omarchy plugin add "$url" --enable --yes || echo "plugin install failed: $url"
      id=$(plugin_id_for_url "$url") || continue
    fi
    plugin_enabled "$id" || omarchy plugin enable "$id" || echo "plugin enable failed: $id"
  done
else
  echo "omarchy-plugin-add not found — skipping shell plugins"
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
