{ inputs, ... }:
{
  perSystem =
    { config, pkgs, templatePackage, ... }:
    {
      packages.homebase-nix = templatePackage ./homebase-nix "bin" {
        inherit (config.packages) bash-postlude bashrc-dir nix;
        inherit (pkgs) bashInteractive jq;
        # The exact nixpkgs revision this flake is pinned to, for `search`:
        nixpkgs_ref = "github:nixos/nixpkgs/${inputs.nixpkgs.rev}";
      };
    };
}
