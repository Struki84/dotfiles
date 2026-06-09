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
# 
# Install gnome extensions
# sudo apt install gnome-shell-extensions
#
# Install gnome tweaks 
# sudo apt install gnome-tweaks
#
# Install gnome shell extensions
# sudo apt install gnome-shell-extensions
#
# Extensions
# - dash to dock
# - internet radio
# - Notification banner reloaded
# - pannel date format
# - rounded window corners
# - simple indication of workspaces
# - sound input & output device chooser
# - top hat
# - tray icons: reloaded
# - user themes (gnome shell extension?)
#
# Copy wallpapers to Pictures
# 
# Copy my gnome theme, icons and curosr theme
# import my gnome settings
# dconf load / < gnome-settings.dconf
# 
