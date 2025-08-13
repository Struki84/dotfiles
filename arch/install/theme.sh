#! /bin/bash

# Install fonts and gtk theme
yay -S --nonconfirm --needed \
  ttf-dejavu ttf-liberation ttf-font-awesome \
  noto-fonts noto-fonts-emoji \
  ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-mono \
  ttf-roboto ttf-roboto-mono \
  flat-remix-gtk

tar -xvf ~/.local/share/dotfiles/arch/icons/Vivid-Glassy-Dark-Icons.tar.gz
mkdir ~/.local/share/icons
mv ~/.local/share/dotfiles/arch/icons/Vivid-Glassy-Dark-Icons ~/.local/share/icons

gsettings set org.gnome.desktop.interface gtk-theme 'Flat-Remix-GTK-Cyan-Darkest'
gsettings set org.gnome.desktop.interface icon-theme 'Vivid-Glassy-Dark-Icons'
gsettings set org.gnome.desktop.interface font-name 'Roboto Regular 11'
gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Roboto Regular 11'

