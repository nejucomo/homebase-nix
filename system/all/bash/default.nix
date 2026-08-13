{
  perSystem =
    { config, pkgs, templatePackage, ... }:
    {
      packages.bash = templatePackage ./bash "bin" {
        inherit (config.packages) bashrc-dir xdg-config;
        inherit (pkgs) bashInteractive;
      };
    };
}
