#!/bin/bash

# Install core shell tools
yay -S --noconfirm --needed \
  xclip ripgrep fzf zoxide fd \
  wget curl zsh eza-git mise \
  wezterm-git tmux-git nvim \
  docker docker-compose docker-buildx \
  github-cli lazygit #lazydocker-git

# Configure docker

# Limit log size to avoid running out of disk
sudo mkdir -p /etc/docker
echo '{"log-driver":"json-file","log-opts":{"max-size":"10m","max-file":"5"}}' | sudo tee /etc/docker/daemon.json

# Start Docker automatically
sudo systemctl enable docker

# Give this user privileged Docker access
sudo usermod -aG docker ${USER}

# Prevent Docker from preventing boot for network-online.target
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo tee /etc/systemd/system/docker.service.d/no-block-boot.conf <<'EOF'
[Unit]
DefaultDependencies=no
EOF

sudo systemctl daemon-reload

# Secrets file placeholder so zsh can load
mkdir -p ~/.config/user
touch ~/.config/user/.secrets

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Instal p10k shell
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k 

# Install zsh plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Install tmux plugins
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm

# Setup oh-my-zsh
cp ~/.local/share/dotfiles/arch/shell/zsh/zshrc ~/.zshrc
cp ~/.local/share/dotfiles/arch/shell/zsh/setup.zsh ~/.oh-my-zsh/custom/setup.zsh

# Setup git user
git config --global user.email simun.strukan@gmail.com
git config --global user.name Simun Strukan

# Set zsh as defualt shell
chsh -s /bin/zsh
