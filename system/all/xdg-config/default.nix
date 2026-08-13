{
  perSystem =
    { config, pkgs, templatePackage, ... }:
    {
      packages.xdg-config = templatePackage ./xdg-config "etc/xdg" {
        inherit (pkgs) nixfmt;
        inherit (config.packages) git-user-hooks bashrc-dir;
      };
    };
}
