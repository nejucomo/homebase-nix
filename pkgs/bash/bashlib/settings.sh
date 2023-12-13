set -o vi

export HOMEBASE_NEST_LEVEL=$(( "${HOMEBASE_NEST_LEVEL:-0}" + 1 ))
export NIX_SHELL_PRESERVE_PROMPT='1'
export EDITOR='vim'
