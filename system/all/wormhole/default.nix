{
  perSystem =
    { pkgs, templatePackage, ... }:
    {
      packages.wormhole = templatePackage ./wormhole "bin" { inherit (pkgs) magic-wormhole; };
    };
}
