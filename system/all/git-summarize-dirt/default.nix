{
  perSystem =
    { config, pkgs, templatePackage, ... }:
    {
      packages.git-summarize-dirt = templatePackage ./git-summarize-dirt "bin" {
        inherit (config.packages) bash-postlude git-current-branch;
        inherit (pkgs) git sd;
      };
    };
}
