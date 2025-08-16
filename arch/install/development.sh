#!/bin/bash

# Install core shell tools
yay -S --nonconfirm --needed \
  xclip ripgrep fzf zoxide fd \
  wget curl zsh eza-git\
  wezterm-git tmux-git nvim \
  imagemagick github-cli lazygit lazydocker-git

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install zsh plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Install tmux plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Setup oh-my-zsh
cp ~/.local/share/dotfiles/arch/shell/zsh/zshrc ~/.zshrc
cp ~/.local/share/dotfiles/arch/shell/zsh/setup.zsh ~/.oh-my-zsh/custom/setup.zsh

# Setup git user
git config --global user.email simun.strukan@gmail.com
git config --global user.name Simun Strukan

# Set zsh as defualt shell
chsh -s /bin/zsh


