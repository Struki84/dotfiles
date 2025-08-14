source ~/.dotfiles/zsh/common.zsh

if [[ "$(uname -s)" == "Darwin" ]]; then
    source ~/.dotfiles/zsh/macos.zsh
elif [[ "$(uname -s)" == "Linux" ]]; then
    source ~/.dotfiles/zsh/linux.zsh
fi

