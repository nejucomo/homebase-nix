{ lib, ... }:
{
  perSystem = (
    { inputs', ... }:
    let
      flakePkgs = {
        inherit (inputs') git-clone-canonical jj;
      };

      flakeAttrDefault = _name: flake: flake.packages.default;

      inherit (lib.attrsets) mapAttrs;
    in
    {
      packages = mapAttrs flakeAttrDefault flakePkgs;
    }
  );
}
