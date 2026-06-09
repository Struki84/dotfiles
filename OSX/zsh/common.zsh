add_to_path() {
  for p in "$@"; do
    [[ ":$PATH:" != *":$p:"* ]] && PATH="$p:$PATH"
  done
}

export GOPATH=$HOME/.go

# ALIASES
#############################################

### My Python aliases
alias python="/usr/bin/python3"
alias pip="/usr/bin/pip3"

### Navigation shortcuts
alias ls="eza -l --icons --group-directories-first"
alias lst="ls -TL 2"
alias lsa="ls -a"
alias lsd="ls -D"

alias eng="~/Engineering/"
alias pro="~/Engineering/Projects/"
alias libs="~/Engineering/Libraries/"
alias sb="~/Engineering/Sandbox/"
alias web="~/Engineering/WebSites/"
alias asai="~/Engineering/Projects/ASAI/SourceCode/Web/"
alias clipt="~/Engineering/Libraries/clipt/"

alias lg="lazygit"

# PATHS
#############################################
add_to_path /usr/local/bin

# Flutter Configurations
#############################################
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
