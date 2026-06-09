#!/bin/bash
# Omarchy theme-set hook: keep personal tmux config bridged + reload live sessions.
BASE="$HOME/.config/tmux/tmux.conf"
LINE="source-file ~/.config/tmux/user.conf"
grep -qxF "$LINE" "$BASE" 2>/dev/null || echo "$LINE" >>"$BASE"
command -v tmux >/dev/null && tmux info &>/dev/null && tmux source-file "$BASE"
