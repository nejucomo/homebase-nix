# This is the wrapper script (defaults to `--worktree`), not the raw
# upstream nixpkgs `claude-code` package - it owns the `claude` name here,
# so the raw package is only used as a build input and is not separately
# exposed under `packages.claude-code` (see system/all/nixpkgs.nix).
{
  perSystem =
    { config, pkgs, templatePackage, ... }:
    {
      packages.claude = templatePackage ./claude "bin" {
        inherit (config.packages) bash-postlude;
        claude-code = pkgs.claude-code;
      };
    };
}
