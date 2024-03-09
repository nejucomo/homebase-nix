function main {
  exec nix-env -qaP --description "$@"
}
