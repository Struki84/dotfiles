#!bin/bash
yay -S --noconfirm --needed \
  gnome-calculator brave-bin ferdium-bin notion-app-electron \
  1password-beta 1password-cli xmind dbeaver rustdesk-bin \
  virtualbox virtualbox-host-modules-arch localsend-bin libreoffice-fresh vlc \
  plex-desktop solaar resilio-sync

# Setup resilion sync

cp ~/.local/share/dotfiles/arch/applications/*.desktop ~/.local/share/applications/
cp ~/.local/share/dotfiles/arch/applications/hidden/*.desktop ~/.local/share/applications/

update-desktop-database ~/.local/share/applications

