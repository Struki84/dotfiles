#!/bin/bash
# Omarchy theme-set hook: re-apply GTK + icon theme after a theme change.
gsettings set org.gnome.desktop.interface icon-theme "Vivid-Glassy-Dark-Icons"
gsettings set org.gnome.desktop.interface gtk-theme "Flat-Remix-GTK-Blue-Darkest"
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
