function main
{
  parse-args 'dir=.' "$@"
  cd "$dir"

  if [ -f ./flake.nix ]
  then
    set -x
    exec nix flake check
  elif [ -f ./Cargo.toml ]
  then
    set -x
    exec cargo checkmate
  else
    fail 'unknown build system'
  fi
}
