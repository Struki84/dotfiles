# setup nvim bin path
export PATH="/opt/nvim-linux64/bin/:$PATH"

export SUDO_EDITOR="nvim"
alias "sudoedit"='function _sudoedit(){sudo -e "$1";};_sudoedit'
