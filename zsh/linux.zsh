# setup nvim bin path
add_to_path $HOME/usr/local/go/bin

export SUDO_EDITOR="nvim"
alias "sudoedit"='function _sudoedit(){sudo -e "$1";};_sudoedit'
