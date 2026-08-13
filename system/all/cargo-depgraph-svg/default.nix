{
  perSystem =
    { pkgs, templatePackage, ... }:
    {
      packages.cargo-depgraph-svg = templatePackage ./cargo-depgraph-svg "bin" {
        inherit (pkgs) cargo-depgraph graphviz;
      };
    };
}
