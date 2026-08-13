{
  perSystem =
    { config, pkgs, templatePackage, ... }:
    {
      packages.set-symlink = templatePackage ./set-symlink "bin" {
        inherit (config.packages) bash-postlude;
        inherit (pkgs) coreutils;
      };
    };
}
