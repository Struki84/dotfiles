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
#
##################################
#
# POPOS SETUP 
# sudo apt update && sudo apt upgrade -y
# 
# Install GNOME Extensions and Tweaks
# sudo apt install gnome-shell-extensions gnome-tweaks -y
# 
# Install Extensions Manager to help install extensions from extensions.gnome.org
# sudo apt install gnome-shell-extension-manager -y
#
# extension-manager --install-extension=1160  # dash to dock
# extension-manager --install-extension=836   # internet radio
# extension-manager --install-extension=4651  # panel date format
# extension-manager --install-extension=5237  # rounded window corners
# extension-manager --install-extension=5081  # simple workspace indicator
# extension-manager --install-extension=906   # sound input/output chooser
# extension-manager --install-extension=5219  # top hat
# extension-manager --install-extension=2890  # tray icons reloaded
#
# Create directories for themes and icons if they don't exist
# mkdir -p ~/.themes ~/.icons ~/.local/share/themes ~/.local/share/icons
# 
# Create Pictures directory for wallpapers if it doesn't exist
# mkdir -p ~/Pictures/Wallpapers
# 
# Copy wallpapers 
# cp -r ~/.dotfiles/popos/apperance/wallpapers/* ~/Pictures/Wallpapers/
# 
# Copy themes and icons (adjust paths as needed)
# cp -r ~/.dotfiles/popos/apperance/flat-remix-gnome/themes/* ~/.themes/
# cp -r ~/.dotfiles/popos/apperance/candy-icons/* ~/.icons/candy-icons/
# cp -r ~/.dotfiles/popos/apperance/volantes_light_cursors/* ~/.icons/volantes_light_cursors/# Copy wallpapers to Pictures
# 
# Import my gnome settings
# dconf load / < ~/.dotfiles/popos/all-settings.dconf
