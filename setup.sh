# Install power10k theme
# git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
# Install nvim
# Install astro vim
# source tmux to custom conf
# source zsh to custom conf
# add custom nvim conf to astro nvim conf
# need to install nerd fonts
# brew tap homebrew/cask-fonts && brew install --cask font-<FONT NAME>-nerd-font || FOR OSX
# install tmux plugin manager: https://github.com/tmux-plugins/tpm
# git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm


#!/bin/bash
DOTFILES_DIR="$HOME/.dotfiles"

# Setup AstroNvim user config
echo "Setting up AstroNvim user config..."
if [ -d ~/.config/nvim ]; then
    rm -rf ~/.config/nvim/lua/user
    ln -s $DOTFILES_DIR/nvim/user ~/.config/nvim/lua/user
    echo "AstroNvim user config linked."
else
    echo "AstroNvim not found. Skipping user config setup."
fi

# Setup WezTerm config
if command -v wezterm &> /dev/null || [ -d "/Applications/WezTerm.app" ]; then
    echo "Setting up WezTerm config..."
    ln -sf $DOTFILES_DIR/term/wezterm.lua ~/.wezterm.lua
    echo "WezTerm config linked."
else
    echo "WezTerm not found. Skipping config setup."
fi

# Setup Zsh configuration
if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "Setting up Zsh configuration..."
    ln -sf $DOTFILES_DIR/zsh/setup.zsh $HOME/.oh-my-zsh/custom/setup.zsh
    echo "Zsh configuration linked."
else
    echo "Oh My Zsh not found. Skipping Zsh setup."
fi

# Setup tmux configuration
if command -v tmux &> /dev/null; then
    echo "Setting up tmux configuration..."
    ln -sf $DOTFILES_DIR/tmux/tmux.conf $HOME/.tmux.conf
    echo "Tmux configuration linked."
else
    echo "Tmux not found. Skipping config setup."
fi

# Load user secrets
if [ -f "$HOME/.config/user/secrets" ]; then
    echo "Loading user secrets..."
    source $HOME/.config/user/secrets
else
    echo "User secrets not found. Skipping user secrets setup."
fi
echo "Dotfiles setup complete!"
