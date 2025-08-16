#! /bin/bash

# Install fonts and gtk theme
yay -S --noconfirm --needed \
  ttf-dejavu ttf-liberation ttf-font-awesome \
  noto-fonts noto-fonts-emoji \
  ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-mono \
  ttf-roboto ttf-roboto-mono \
  flat-remix-gtk sddm-astronaut-theme

# Unzip the icons that are included with with the dotiles
mkdir ~/.local/share/icons
tar -xvf ~/.local/share/dotfiles/arch/icons/Vivid-Glassy-Dark-Icons.tar.gz
mv ~/.local/share/dotfiles/arch/icons/Vivid-Glassy-Dark-Icons ~/.local/share/icons

# Setup the wallpapers
mkdir ~/Pictures/Wallpapers
cp -R ~/.local/share/dotfiles/wallpapers/* ~/Pictures/Wallpapers/

wallpaper=~/.local/share/dotfiles/wallpapers/wallpaper-1.jpg

magick "$wallpaper" -crop 2560x1440+0+0 ~/.config/hypr/wallpaper/left.jpg
magick "$wallpaper" -crop 2560x1440+2560+0 ~/.config/hypr/wallpaper/right.jpg

hyprctl hyprpaper unload all
hyprctl hyprpaper preload "~/.config/hypr/wallpaper/left.jpg"
hyprctl hyprpaper preload "~/.config/hypr/wallpaper/right.jpg"
hyprctl hyprpaper wallpaper "dp-2,~/.config/hypr/wallpaper/left.jpg"
hyprctl hyprpaper wallpaper "dp-3,~/.config/hypr/wallpaper/right.jpg"

# Setup the theme and fonts for all gtk based apps
gsettings set org.gnome.desktop.interface gtk-theme 'Flat-Remix-GTK-Cyan-Darkest'
gsettings set org.gnome.desktop.interface icon-theme 'Vivid-Glassy-Dark-Icons'
gsettings set org.gnome.desktop.interface font-name 'Roboto Regular 11'
gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Roboto Regular 11'

# Set SDDM Astronaut theme as default
echo "[Theme]
Current=sddm-astronaut-theme" | sudo tee /etc/sddm.conf

# Set specific SDDM theme variant (change 'astronaut.conf' to your desired one, e.g., 'cyberpunk.conf')
sudo sed -i 's/^ConfigFile=.*/ConfigFile=Themes\/astronaut.conf/' /usr/share/sddm/themes/sddm-astronaut-theme/metadata.desktop
