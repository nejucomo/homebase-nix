set -o vi

export EDITOR='vim'
export HOMEBASE_NEST_LEVEL=$(( "${HOMEBASE_NEST_LEVEL:-0}" + 1 ))
export GTK_THEME='Adwaita:dark'
export NIX_INDEX_DATABASE='/usr/local/usershare/knack/nix-index'
export NIX_SHELL_PRESERVE_PROMPT='1'
export PATH="$HOME/.cargo/bin:$PATH"
export RUSTDOCFLAGS='-D warnings'
