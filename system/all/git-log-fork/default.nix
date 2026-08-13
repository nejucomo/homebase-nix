{
  perSystem =
    { config, pkgs, templatePackage, ... }:
    {
      packages.git-log-fork = templatePackage ./git-log-fork "bin" {
        inherit (config.packages) bash-postlude;
        inherit (pkgs) bash git;
      };
    };
}
