source ~/.dotfiles/OSX/zsh/common.zsh

if [[ "$(uname -s)" == "Darwin" ]]; then
    source ~/.dotfiles/OSX/zsh/macos.zsh
elif [[ "$(uname -s)" == "Linux" ]]; then
    source ~/.dotfiles/OSX/zsh/linux.zsh
fi