{
  perSystem =
    { config, pkgs, templatePackage, ... }:
    {
      packages.zellij = templatePackage ./zellij "bin" {
        inherit (config.packages) xdg-config;
        inherit (pkgs) zellij;
      };
    };
}
