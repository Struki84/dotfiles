# ALIASES
#############################################

### My Python aliases
alias python="/usr/bin/python3"
alias pip="/usr/bin/pip3"

### Navigation shortcuts
alias ls="ls -l"
alias lsa="ls -la"
alias eng="/Users/Simun/Engineering"
alias pro="/Users/Simun/Engineering/Projects"
alias libs="/Users/Simun/Engineering/Libraries"
alias tg="/Users/Simun/Engineering/TestingGrounds"
alias asai="cd ~/Engineering/Projects/ASAI/SourceCode/Web/"

# PATHS
#############################################
export PATH=/usr/local/bin:$PATH
export PATH=/usr/local/mysql/bin:$PATH

# RBENV
#############################################
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
eval "$(rbenv init - zsh)"

# Flutter Configurations
#############################################
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion