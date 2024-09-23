add_to_path() {
  for p in "$@"; do
    [[ ":$PATH:" != *":$p:"* ]] && PATH="$p:$PATH"
  done
}

# ALIASES
#############################################

### My Python aliases
alias python="/usr/bin/python3"
alias pip="/usr/bin/pip3"

### Navigation shortcuts
alias ls="ls -l"
alias lsa="ls -la"
alias eng="~/Engineering/"
alias pro="~/Engineering/Projects/"
alias libs="~/Engineering/Libraries/"
alias tg="~/Engineering/TestingGrounds/"
alias web="~/Engineering/WebSites/"
alias asai="~/Engineering/Projects/ASAI/SourceCode/Web/"

# PATHS
#############################################
add_to_path /usr/local/bin

# Flutter Configurations
#############################################
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
