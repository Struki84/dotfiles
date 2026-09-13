add_to_path() {
  for p in "$@"; do
    [[ ":$PATH:" != *":$p:"* ]] && PATH="$p:$PATH"
  done
}

export GOPATH=$HOME/.go

add_to_path /usr/local/bin
add_to_path /usr/local/go/bin
add_to_path $DOTFILES/quattro/bin
add_to_path $GOPATH/bin
