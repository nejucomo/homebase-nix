export PATH="$HOME/.cargo/bin:$PATH"

export NIX_INDEX_DATABASE='/usr/local/usershare/knack/nix-index'
export NIX_REGISTRY='nixpkgs=github:NixOS/nixpkgs/25.05'
export NIX_SHELL_PRESERVE_PROMPT='1'
export RUSTDOCFLAGS="$RUSTFLAGS"
export RUSTFLAGS='-D warnings'

# sccache disabled due to a race condition(?)
# Disable incremental builds and rely solely on `sccache`:
# export CARGO_INCREMENTAL='false'
# export RUSTC_WRAPPER="$(which sccache)"
