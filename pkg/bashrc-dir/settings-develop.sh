# These are settings that are safe to set in `nix develop` shells.
# They should aim to not interfere with hermetic builds (so no PATH tweaks, build flags, etc...)
 
set -o vi

export GTK_THEME='Adwaita:dark'
export HOMEBASE_NEST_LEVEL=$(( "${HOMEBASE_NEST_LEVEL:-0}" + 1 ))
export EDITOR='hx'
