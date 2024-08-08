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

# Check if --dry-run flag is used
DRY_RUN=false
if [ "$1" == "--dry-run" ]; then
    DRY_RUN=true
    echo "Performing a dry run. No changes will be made."
fi

# Function to handle linking
link_file() {
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY RUN] Would link $1 to $2"
    else
        ln -sf "$1" "$2"
        echo "Linked $1 to $2"
    fi
}

# Setup AstroNvim user config
echo "Setting up AstroNvim user config..."
if [ -d ~/.config/nvim ]; then
    if [ "$DRY_RUN" = false ]; then
        rm -rf ~/.config/nvim/lua/user
    else
        echo "[DRY RUN] Would remove ~/.config/nvim/lua/user"
    fi
    link_file "$DOTFILES_DIR/nvim/user" ~/.config/nvim/lua/user
else
    echo "AstroNvim not found. Skipping user config setup."
fi

# Setup WezTerm config
if command -v wezterm &> /dev/null; then
    echo "Setting up WezTerm config..."
    link_file "$DOTFILES_DIR/term/wezterm.lua" ~/.wezterm.lua
else
    echo "WezTerm not found. Skipping config setup."
fi

# Setup Zsh configuration
if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "Setting up Zsh configuration..."
    link_file "$DOTFILES_DIR/zsh/setup.zsh" "$HOME/.oh-my-zsh/custom/setup.zsh"
else
    echo "Oh My Zsh not found. Skipping Zsh setup."
fi

# Setup tmux configuration
if command -v tmux &> /dev/null; then
    echo "Setting up tmux configuration..."
    link_file "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
else
    echo "Tmux not found. Skipping config setup."
fi

echo "Dotfiles setup complete!"
