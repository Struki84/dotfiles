# setup nvim bin path
add_to_path /opt/nvim-linux64/bin

export SUDO_EDITOR="nvim"
alias "sudoedit"='function _sudoedit(){sudo -e "$1";};_sudoedit'
