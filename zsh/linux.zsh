# setup nvim bin path
add_to_path /usr/local/go/bin
add_to_path $GOPATH/bin

export SUDO_EDITOR="nvim"
alias "sudoedit"='function _sudoedit(){sudo -e "$1";};_sudoedit'
