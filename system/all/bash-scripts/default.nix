{
  perSystem =
    { config, templatePackage, ... }:
    {
      packages.bash-scripts = templatePackage ./bash-scripts "bin" {
        inherit (config.packages) bash-postlude;
      };
    };
}
