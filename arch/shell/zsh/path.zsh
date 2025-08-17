add_to_path() {
  for p in "$@"; do
    [[ ":$PATH:" != *":$p:"* ]] && PATH="$p:$PATH"
  done
}

add_to_path /usr/local/bin
add_to_path /usr/local/go/bin
add_to_path $HOME/.local/share/dotfiles/arch/bin

export GOPATH=$HOME/.go
add_to_path $GOPATH/bin
