{
  perSystem =
    { config, pkgs, templatePackage, ... }:
    {
      packages.homebase-nix = templatePackage ./homebase-nix "bin" {
        inherit (config.packages) bash-postlude bashrc-dir nix;
        inherit (pkgs) bashInteractive;
      };
    };
}
