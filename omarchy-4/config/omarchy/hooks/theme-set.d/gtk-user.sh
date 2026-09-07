#!/bin/bash
# Omarchy theme-set hook: re-apply my GTK + icon theme.
# omarchy-theme-set-gnome resets gtk-theme/icon-theme on every theme change;
# hooks run after it, so this puts them back.
gsettings set org.gnome.desktop.interface icon-theme "Vivid-Glassy-Dark-Icons"
gsettings set org.gnome.desktop.interface gtk-theme "Flat-Remix-GTK-Blue-Darkest"
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
