#!/bin/bash
# Tell every running nvim to re-read the Omarchy theme and re-apply its colorscheme.
shopt -s nullglob
for sock in "${XDG_RUNTIME_DIR:-/run/user/$UID}"/nvim.*; do
  [ -S "$sock" ] || continue
  nvim --server "$sock" --remote-send '<Cmd>OmarchyReloadTheme<CR>' 2>/dev/null || true
done
