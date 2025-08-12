#!/bin/bash

yay -S --nonconfirm --needed \
  libappindicator-gtk3 network-manager-applet  blueberry bluez \
  swaync wlogout gnome-calendar nautilus gvfs ffmpegthumbnailer \
  slurp satty mpv evince imv wf-recorder

# Install fonts
yay -S --nonconfirm --needed \
  ttf-dejavu ttf-liberation ttf-font-awesome \
  noto-fonts noto-fonts-emoji \
  ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-mono 
  
# Install core shell tools
yay -S --nonconfirm --needed \
  curl zsh eza-git\
  wezterm-git tmux-git
