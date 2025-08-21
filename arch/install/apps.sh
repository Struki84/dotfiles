#!bin/bash
yay -S --noconfirm --needed \
  gnome-calculator ferdium-bin notion-app-electron \
  1password-beta 1password-cli xmind dbeaver rustdesk-bin \
  virtualbox virtualbox-host-modules-arch localsend-bin libreoffice-fresh vlc \
  plex-desktop solaar rslsync

# Setup resilio sync
sudo usermod -aG $(id -gn) rslsync
sudo usermod -aG rslsync $USER

mkdir -p $HOME/.rslsync
sudo chmod g+rw $HOME/.rslsync/

systemctl --user enable rslsync
systemctl --user start rslsync

cp ~/.local/share/dotfiles/arch/applications/*.desktop ~/.local/share/applications/
cp ~/.local/share/dotfiles/arch/applications/hidden/*.desktop ~/.local/share/applications/

update-desktop-database ~/.local/share/applications

# Need to run manually to setup the online accounts/google calendar with gnome-calendar
# XDG_CURRENT_DESKTOP=GNOME gnome-control-center online-accounts

