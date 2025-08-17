#!/bin/bash
echo "script path: $PATH" >&2

sudo pacman -Sy --noconfirm --needed git

# Manually install yay from AUR if not already available
if ! command -v yay &>/dev/null; then
  # Install build tools
  sudo pacman -Sy --needed --noconfirm base-devel
  cd /tmp
  rm -rf yay-bin
  git clone https://aur.archlinux.org/yay-bin.git
  cd yay-bin
  makepkg -si --noconfirm
  cd -
  rm -rf yay-bin
  cd ~
fi

# I screwed this up, and just c/p from omarchy without checking the paths...:facepalm
# Setup GPG configuration with multiple keyservers for better reliability
# sudo mkdir -p /etc/gnupg
# sudo cp ~/.local/share/omarchy/default/gpg/dirmngr.conf /etc/gnupg/
# sudo chmod 644 /etc/gnupg/dirmngr.conf
# sudo gpgconf --kill dirmngr || true
# sudo gpgconf --launch dirmngr || true

# Add fun and color to the pacman installer
if ! grep -q "ILoveCandy" /etc/pacman.conf; then
  sudo sed -i '/^\[options\]/a Color\nILoveCandy' /etc/pacman.conf
fi

# Install iwd explicitly if it wasn't included in archinstall
# This can happen if archinstall used ethernet
if ! command -v iwctl &>/dev/null; then
  yay -S --noconfirm --needed iwd
  sudo systemctl enable --now iwd.service
fi

# Prevent systemd-networkd-wait-online timeout on boot
sudo systemctl disable systemd-networkd-wait-online.service
sudo systemctl mask systemd-networkd-wait-online.service

# Copy the custom config files
cp -R ~/.local/share/dotfiles/arch/config/* ~/.config/

# Ensure application directory exists for update-desktop-database
mkdir -p ~/.local/share/applications

# This computer runs on power outlet
yay -S --noconfirm power-profiles-daemon
powerprofilesctl set performance || true

# Solve common flakiness with SSH
echo "net.ipv4.tcp_mtu_probing=1" | sudo tee -a /etc/sysctl.d/99-sysctl.conf

