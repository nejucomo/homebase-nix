set -o vi

export HOMEBASE_NEST_LEVEL=$(( "${HOMEBASE_NEST_LEVEL:-0}" + 1 ))
export NIX_SHELL_PRESERVE_PROMPT='1'
export NIX_INDEX_DATABASE='/usr/local/usershare/knack/nix-index'
export EDITOR='vim'
