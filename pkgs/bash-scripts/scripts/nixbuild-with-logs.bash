function main
{
  nix build --print-build-logs "$@"
}
