{
  perSystem =
    { config, pkgs, templatePackage, ... }:
    {
      packages.homebase-nix-develop = templatePackage ./homebase-nix-develop "bin" {
        inherit (config.packages) bashrc-dir nix;
        inherit (pkgs) bashInteractive;
      };
    };
}
