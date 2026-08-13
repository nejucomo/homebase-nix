{
  perSystem =
    { config, pkgs, templatePackage, ... }:
    {
      packages.git-copy-remotes = templatePackage ./git-copy-remotes "bin" {
        inherit (config.packages) bash-postlude;
        inherit (pkgs) bash git;
      };
    };
}
