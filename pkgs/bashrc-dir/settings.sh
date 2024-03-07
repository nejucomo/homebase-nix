set -o vi

unset XDG_CONFIG_HOME # Unset this when inherited from leftwm

export EDITOR='hx'
export GTK_THEME='Adwaita:dark'
export HOMEBASE_NEST_LEVEL=$(( "${HOMEBASE_NEST_LEVEL:-0}" + 1 ))
export NIX_INDEX_DATABASE='/usr/local/usershare/knack/nix-index'
export NIX_SHELL_PRESERVE_PROMPT='1'
export PATH="$HOME/.cargo/bin:$PATH"
export RUSTFLAGS='-D warnings'
export RUSTDOCFLAGS="$RUSTFLAGS"
