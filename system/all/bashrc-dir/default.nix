{
  perSystem =
    { config, pkgs, templatePackage, ... }:
    {
      packages.bashrc-dir = templatePackage ./bashrc-dir "etc/bashrc-dir" {
        inherit (pkgs) sd;
        inherit (config.packages) git-summarize-dirt;
      };
    };
}
