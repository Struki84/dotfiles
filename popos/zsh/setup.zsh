source ~/.local/share/dotfiles/popos/zsh/common.zsh

if [[ "$(uname -s)" == "Darwin" ]]; then
    source ~/.local/share/dotfiles/popos/zsh/macos.zsh
elif [[ "$(uname -s)" == "Linux" ]]; then
    source ~/.local/share/dotfiles/popos/zsh/linux.zsh
fi

