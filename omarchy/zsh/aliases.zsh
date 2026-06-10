### Navigation shortcuts
alias ls="eza -l --icons --group-directories-first"
alias lst="eza -TL 2 --icons --group-directories-first"
alias lsa="eza -a"
alias lsd="eza -D"

alias eng="~/Engineering/"
alias pro="~/Engineering/Projects/"
alias libs="~/Engineering/Libraries/"
alias sb="~/Engineering/Sandbox"
alias web="~/Engineering/WebSites/"
alias asai="~/Engineering/Projects/ASAI/SourceCode"
alias clipt="~/Engineering/Libraries/clipt/"

alias lg="lazygit"

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
  elif [ -n "$VIRTUAL_ENV" ]; then
    # Deactivate only once we've left the venv's project tree.
    # (case-glob does a real prefix match; the old `[ ... != ...* ]` did not.)
    local proj="$(dirname "$VIRTUAL_ENV")"
    case "$PWD/" in
      "$proj"/*) ;;  # still inside project -> keep venv active
      *) deactivate 2>/dev/null || true ;;
    esac
  fi
}
