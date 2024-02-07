function main
{
  parse-args 'dir=.' "$@"
  cd "$dir"

  if [ -f ./flake.nix ]
  then
    exec nix flake check
  elif [ -f ./Cargo.toml ]
  then
    exec cargo checkmate
  else
    fail 'unknown build system'
  fi
}
