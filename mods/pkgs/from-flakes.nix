{ lib, ... }:
{
  perSystem = (
    { inputs', ... }:
    let
      # git-clone-canonical is deliberately absent here: mods/hbpkgs.nix
      # wraps it and exposes the wrapper under that name instead.
      flakePkgs = {
        # inherit (inputs') jj;
      };

      flakeAttrDefault = _name: flake: flake.packages.default;

      inherit (lib.attrsets) mapAttrs;
    in
    {
      packages = mapAttrs flakeAttrDefault flakePkgs;
    }
  );
}
