set -o vi

export EDITOR='hx'
export GTK_THEME='Adwaita:dark'
export HOMEBASE_NEST_LEVEL=$(( "${HOMEBASE_NEST_LEVEL:-0}" + 1 ))
export NIX_INDEX_DATABASE='/usr/local/usershare/knack/nix-index'
export NIX_SHELL_PRESERVE_PROMPT='1'
export PATH="$HOME/.cargo/bin:$PATH"
export RUSTFLAGS='-D warnings'
export RUSTDOCFLAGS="$RUSTFLAGS"

# sccache disabled due to a race condition(?)
# Disable incremental builds and rely solely on `sccache`:
# export CARGO_INCREMENTAL='false'
# export RUSTC_WRAPPER="$(which sccache)"
