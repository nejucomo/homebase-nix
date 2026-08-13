{
  perSystem =
    { config, pkgs, templatePackage, ... }:
    {
      packages.nix = templatePackage ./nix "bin" {
        inherit (config.packages) bash-postlude;
        inherit (pkgs) nix;
      };
    };
}
