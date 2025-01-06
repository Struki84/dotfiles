# Step 0:
# sudo apt update && sudo apt upgrade -y
#
# Install zsh and oh-my-zsh
# sudo apt install zsh curl git -y
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
#
# Install zash-autosuggestions and zsh-syntax-highlighting
# 
# Install better ls tool called eza 
# sudo mkdir -p /etc/apt/keyrings
# wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
# echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo $ tee /etc/apt/sources.list.d/gierens.list
# sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
# sudo apt update && sudo apt install -y eza
# 
# Set sym link to .zshrc
# ln -s /home/simun/.dotfiles/zsh/zshrc /home/simun/.zshrc
#
# Install Wezterm (load mu config)
# curl -fsSL https://apt.fury.io/wezfurlong/gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/wezfurlong-archive-keyring.gpg
# echo "deb [signed-by=/usr/share/keyrings/wezfurlong-archive-keyring.gpg] https://apt.fury.io/wezfurlong/ * *" | sudo tee /etc/apt/sources.list.d/wezfurlong.list
# sudo apt update
# sudo apt install wezterm -y
#
# Install Tmux
# sudo apt install tmux -y
#
# Install tmux plugin manager
# git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
#
# Instal p10k shell
# git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
# 
# mkdir -p ~/.local/share/fonts
# cd ~/.local/share/fonts && curl -fLo "MesloLGS NF Regular.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
# curl -fLo "MesloLGS NF Bold.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
# curl -fLo "MesloLGS NF Italic.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
# curl -fLo "MesloLGS NF Bold Italic.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf
# fc-cache -f -v
#
# Install neovim
# Install astronvim
# Load my nvim settings
# copy fonts to ~/.local/share/fonts
#
# Insall yarn and npm
# sudo apt install yarn npm -y
#
# Instal go 
# sudo apt install golang -y
#
##################################
#
# POPOS SETUP 
# Check GNOME version
# gnome-shell --version

# System update
# sudo apt update && sudo apt upgrade -y
# 
# Install GNOME Extensions and Tweaks
# sudo apt install gnome-shell-extensions gnome-tweaks gnome-shell-extension-manager -y
#
# Install Extensions
# extension-manager --install-extension=1160  # dash to dock
# extension-manager --install-extension=836   # internet radio
# extension-manager --install-extension=4651  # panel date format
# extension-manager --install-extension=5237  # rounded window corners
# extension-manager --install-extension=5081  # simple workspace indicator
# extension-manager --install-extension=906   # sound input/output chooser
# extension-manager --install-extension=5219  # top hat
# extension-manager --install-extension=2890  # tray icons reloaded
#
# Create directories for themes and icons
# mkdir -p ~/.themes ~/.icons ~/.local/share/themes ~/.local/share/icons
# 
# Create Pictures directory for wallpapers
# mkdir -p ~/Pictures/Wallpapers
# 
# Copy wallpapers 
# cp -r ~/.dotfiles/popos/apperance/wallpapers/* ~/Pictures/Wallpapers/
# 
# Copy themes and icons
# cp -r ~/.dotfiles/popos/apperance/flat-remix-gnome/themes/* ~/.themes/
# cp -r ~/.dotfiles/popos/apperance/candy-icons/* ~/.icons/candy-icons/
# cp -r ~/.dotfiles/popos/apperance/volantes_light_cursors/* ~/.icons/volantes_light_cursors/
# 
# Import gnome settings
# dconf load / < ~/.dotfiles/popos/all-settings.dconf
#
#
# Secure things to remove from gnome all-settings
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
# Installed Apps
# - discord
# - ferdium w
# - trello
# - xmind for linux
# - betterbird
# - db beaver
# - plex
# - remina
# - Solaar
# - brave
# - vlc
# - boxes
# - resilio sync
# - docker
