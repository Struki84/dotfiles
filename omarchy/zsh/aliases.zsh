### Navigation shortcuts
alias ls="eza -l --icons --group-directories-first"
alias lst="ls -TL 2"
alias lsa="ls -a"
alias lsd="ls -D"
alias eng="~/Engineering/"
alias pro="~/Engineering/Projects/"
alias libs="~/Engineering/Libraries/"
alias tg="~/Engineering/TestingGrounds/"
alias web="~/Engineering/WebSites/"
alias asai="~/Engineering/Projects/ASAI/SourceCode/Web/"
alias clipt="~/Engineering/Libraries/clipt/"

export SUDO_EDITOR="nvim"
alias "sudoedit"='function _sudoedit(){sudo -e "$1";};_sudoedit'

if command -v pyenv 1>/dev/null 2>&1; then
  python() {
    if [[ -n "${VIRTUAL_ENV}" ]]; then
      "${VIRTUAL_ENV}/bin/python" "$@"
    else
      command python3 "$@"
    fi
  }
fi

# Auto-activate pyenv version + venv when entering a project
function cd() {
  builtin cd "$@"

  if [ -f .python-version ] && command -v pyenv >/dev/null; then
    pyenv local $(cat .python-version)
  fi

  if [ -d ".venv" ]; then
    source .venv/bin/activate 2>/dev/null || true
  elif [ -n "$VIRTUAL_ENV" ] && [ "$PWD" != "$(dirname $VIRTUAL_ENV)"* ]; then
    deactivate 2>/dev/null || true
  fi
}
