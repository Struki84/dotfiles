################
# GNOME SETUP ##
################
#
# Check GNOME version
# gnome-shell --version
#
# System update
# sudo apt update && sudo apt upgrade -y
# 
# Install GNOME Extensions and Tweaks
# sudo apt install gnome-shell-extensions gnome-tweaks gnome-shell-extension-manager -y
# 
# Copy my GNOME and GTK theme
# mkdir -p ~/.themes 
# cp -r ~/.dotfiles/popos/themes/* ~/.themes/
# If fresh dinwload of Flat-Remix-Blue-Darkest is used modify the
# gnome-shell.css file inside the theme. Change the padding on line 2863
# to padding: 8px 12px 0px 0px;
# 
# Copy Wallpapers / Backgrounds
# cp -r ~/.dotfiles/popos/wallpapers/* ~/.local/share/backgrounds
# 
# Download and copy Icons
# wget https://github.com/EliverLara/candy-icons/archive/refs/heads/master.zip
# mkdir -p ~/.icons
# unzip master.zip
# mv candy-icons-master ~/.icons
# rm master.zip
#
# Copy fonts
# cp -r ~/.dotfiles/popos/fonts/* ~/.local/share/fonts
#
# Install Extensions
#
# install_extensions() {
#     # Array of extension IDs and their names
#     local extension_ids=(
#         1160    # dash to dock
#         836     # internet radio
#         5237    # rounded window corners
#         5081    # simple workspace indicator
#         906     # sound input/output chooser
#         5219    # top hat
#         2890    # tray icons reloaded
#     )
#
#     # Install all required dependencies for extensions
#     sudo apt install -y \
#         libgstreamer-plugins-base1.0-dev \
#         gstreamer1.0-plugins-base-apps \
#         gstreamer1.0-plugins-good \
#         gstreamer1.0-plugins-bad \
#         gstreamer1.0-plugins-ugly \
#         gstreamer1.0-libav \
#         gir1.2-gtop-2.0 \
#         libgtop2-dev
#
#     # Get GNOME Shell version for compatibility
#     local shell_version=$(gnome-shell --version | cut -d ' ' -f 3)
#
#     # Install each extension
#     for id in "${extension_ids[@]}"; do
#         echo "Installing extension ID: $id"
#         wget -O extension.zip "https://extensions.gnome.org/download-extension/extension.v${shell_version}.shell-extension.zip?version_tag=${shell_version}"
#         gnome-extensions install extension.zip
#         rm extension.zip
#     done
# }
#
# # Call the function to install extensions
# install_extensions
# 
# Import gnome settings
# dconf load / < ~/.dotfiles/popos/all-settings.dconf
#
########################
## APPS INSTALLATIONS ##
########################
#
# Installed discord
# wget "https://discord.com/api/download?platform=linux&format=deb" -O discord.deb
# sudo dpkg -i discord.deb
# sudo apt install -f # Install dependencies if needed
# rm discord.deb
# 
# Install ferdium
# Get latest Ferdium version and download URL
# FERDIUM_LATEST=$(curl -s https://api.github.com/repos/ferdium/ferdium-app/releases/latest | grep -o "https://.*amd64.deb")
# wget "$FERDIUM_LATEST" -O ferdium.deb
# sudo dpkg -i ferdium.deb
# sudo apt install -f
# rm ferdium.deb

# Install xmind for linux
# wget https://www.xmind.app/zen/download/linux_deb/ -O xmind.deb
# sudo dpkg -i xmind.deb
# sudo apt install -f  # Install any missing dependencies
# rm xmind.deb
#
# Install DBeaver Community
# wget https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb -O dbeaver.deb
# sudo dpkg -i dbeaver.deb
# sudo apt install -f # Install dependencies if needed
# rm dbeaver.deb
#
# Install remina
# sudo apt install remmina -y
# 
# Install Solaar
# sudo apt install solaar -y 

# Install brave 
# curl -fsS https://dl.brave.com/install.sh | sh
# Install vlc
# sudo apt install vlc -y 
#
# Install boxes VM
# 
# sudo apt install gnome-boxes -y
#
# Install resilio sync
# curl -LO http://linux-packages.resilio.com/resilio-sync/key.asc
# sudo apt-key add ./key.asc
# echo "deb http://linux-packages.resilio.com/resilio-sync/deb resilio-sync non-free" | sudo tee /etc/apt/sources.list.d/resilio-sync.list
# sudo apt update
# sudo apt install resilio-sync -y
#
# Install docker
# sudo apt-get update
# sudo apt-get install ca-certificates curl gnupg
# sudo install -m 0755 -d /etc/apt/keyrings
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
# sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources
# echo \
#   "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
#   "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
#   sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# sudo apt update
# sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
#
# Install Wezterm from GitHub releases
# WEZTERM_LATEST=$(curl -s https://api.github.com/repos/wez/wezterm/releases/latest | grep -o "https://.*Ubuntu22.04.deb" | head -n 1)
# wget -O wezterm.deb $WEZTERM_LATEST
# sudo dpkg -i wezterm.deb
# sudo apt install -f # Install dependencies if needed
# rm wezterm.deb
#
# Install zsh and oh-my-zsh
# sudo apt install zsh -y
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
#
# Install zash-autosuggestions and zsh-syntax-highlighting
# git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
# 
# Install better ls tool called eza 
#sudo mkdir -p /etc/apt/keyrings
# wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
# echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
# sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
# sudo apt update
# sudo apt install -y eza
# 
# Instal p10k shell
# git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
#
# Install Tmux
# sudo apt install tmux -y
#
# Install tmux plugin manager
# git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
#
# Install neovim
# curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
# chmod u+x nvim.appimage
# sudo mv nvim.appimage /usr/local/bin/nvim
#
# Install astronvim
# mv ~/.config/nvim ~/.config/nvim.bak
# mv ~/.local/share/nvim ~/.local/share/nvim.bak
# mv ~/.local/state/nvim ~/.local/state/nvim.bak
# mv ~/.cache/nvim ~/.cache/nvim.bak
# 
# wget https://github.com/AstroNvim/AstroNvim/archive/refs/tags/v3.45.3.tar.gz
# tar xzf v3.45.3.tar.gz
# mv AstroNvim-3.45.3 ~/.config/nvim
# 
#
# Insall yarn and npm
# sudo apt install yarn npm -y
#
# Instal go 
# sudo apt install golang -y
#
# Install wmctrl for custom shortcuts
# sudo apt install wmctrl
#
####################################################
# Secure things need removing from gnome all-settings
#
# [org/blueman/plugins/recentconns]
# recent-connections=[{'adapter': 'CC:47:40:FD:8C:DF', 'address': 'C8:2B:6B:4D:E6:6A', 'alias': 'JBL TUNE525BT', 'icon': 'audio-headphones', 'name': 'Audio and input profiles', 'uuid': '00000000-0000-0000-0000-000000000000', 'time': '1710161118.2603862'}, {'adapter': 'CC:47:40:FD:8C:DF', 'address': '07:17:09:05:0E:25', 'alias': 'Matias Wireless Keyboard', 'icon': 'input-keyboard', 'name': 'Audio and input profiles', 'uuid': '00000000-0000-0000-0000-000000000000', 'time': '1714150313.5391262'}]
#
# [org/gnome/desktop/background]
# picture-uri='file:///home/simun/Pictures/Wallpapers/Originals/wp4473711-5120x1440-wallpapers.jpg'
# picture-uri-dark='file:///home/simun/.local/share/backgrounds/2024-05-28-13-45-39-wallpapersden.com_minimalist-black-digital-blend_5120x1440.jpg'
#
# [org/gnome/desktop/screensaver]
# picture-uri='file:///home/simun/Pictures/Wallpapers/Originals/wp4473711-5120x1440-wallpapers.jpg'
#
# [org/gnome/desktop/remote-desktop/rdp]
# enable=true
# tls-cert='/home/simun/.local/share/gnome-remote-desktop/rdp-tls.crt'
# tls-key='/home/simun/.local/share/gnome-remote-desktop/rdp-tls.key'
#
# [org/gnome/settings-daemon/plugins/color]
# night-light-last-coordinates=(43.500800719942404, 16.441099999999999)
#
# [org/gnome/shell/extensions/network-stats]
# devices-info='{"enp5s0":{"totalUpload":1620033,"totalDownload":3876563,"resetedAt":"Mon Jan 06 2025 00:04:33 GMT+0100 (CET)"},"wlp4s0":{"totalUpload":0,"totalDownload":0,"resetedAt":"Mon Jan 06 2025 00:04:33 GMT+0100 (CET)"}}'
#
# [org/gnome/Weather]
# automatic-location=false
# locations=[<(uint32 2, <('Zagreb', 'LDZA', true, [(0.79819723876097581, 0.28041623897151979)], [(0.79936079741340282, 0.27925268031909273)])>)>]
#
# [org/gnome/shell/weather]
# automatic-location=false
# locations=[<(uint32 2, <('Zagreb', 'LDZA', true, [(0.79819723876097581, 0.28041623897151979)], [(0.79936079741340282, 0.27925268031909273)])>)>]
#
# [org/gnome/file-roller/file-selector]
# current-folder='file:///home/simun/Downloads'
#
# [org/gnome/gedit/plugins/filebrowser]
# virtual-root='file:///home/simun/Engineering/Projects/Mar-Mar-AI/SourceCode/sdk/rest'
#
# ########################
# Configure Resilio sync##
# ########################
# sudo usermod -aG user_group rslsync
# sudo usermod -aG rslsync user_name
# sudo chmod g+rw synced_folder
# systemctl --user enable resilio-syncsystemctl --user enable resilio-sync
# systemctl --user start resilio-sync
#
