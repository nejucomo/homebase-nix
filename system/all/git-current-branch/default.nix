{
  perSystem =
    { config, pkgs, templatePackage, ... }:
    {
      packages.git-current-branch = templatePackage ./git-current-branch "bin" {
        inherit (config.packages) bash-postlude;
        inherit (pkgs) git sd;
      };
    };
}
