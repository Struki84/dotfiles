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
tar -xvf ~/.local/share/dotfiles/arch/icons/Vivid-Glassy-Dark-Icons.tar.gz -C ~/.local/share/icons

# Setup the wallpapers
mkdir -p ~/Pictures/Wallpapers
cp -R ~/.local/share/dotfiles/wallpapers/* ~/Pictures/Wallpapers/

wallpaper=~/.local/share/dotfiles/wallpapers/wallpaper-1.jpg

magick "$wallpaper" -crop 2560x1440+0+0 ~/.config/hypr/wallpaper/left.jpg
magick "$wallpaper" -crop 2560x1440+2560+0 ~/.config/hypr/wallpaper/right.jpg

if ! pgrep -x "hyprpaper" > /dev/null; then 
	hyprpaper &
	sleep 1
fi

hyprctl hyprpaper unload all
hyprctl hyprpaper preload "~/.config/hypr/wallpaper/left.jpg"
hyprctl hyprpaper preload "~/.config/hypr/wallpaper/right.jpg"
hyprctl hyprpaper wallpaper "DP-2,~/.config/hypr/wallpaper/left.jpg"
hyprctl hyprpaper wallpaper "DP-3,~/.config/hypr/wallpaper/right.jpg"

cp -r /usr/share/themes/Flat-Remix-GTK-Cyan-Darkest/gtk-4.0/* ~/.config/gtk-4.0/

# Setup the theme and fonts for all gtk based apps
gsettings set org.gnome.desktop.interface gtk-theme 'Flat-Remix-GTK-Cyan-Darkest'
gsettings set org.gnome.desktop.interface icon-theme 'Vivid-Glassy-Dark-Icons'
gsettings set org.gnome.desktop.interface font-name 'Roboto Regular 11'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

# Set SDDM Astronaut theme as default
echo "[Theme]
Current=sddm-astronaut-theme" | sudo tee /etc/sddm.conf

# Set specific SDDM theme variant (change 'astronaut.conf' to your desired one, e.g., 'cyberpunk.conf')
sudo sed -i 's/^ConfigFile=.*/ConfigFile=Themes\/astronaut.conf/' /usr/share/sddm/themes/sddm-astronaut-theme/metadata.desktop
