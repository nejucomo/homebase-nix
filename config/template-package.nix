# Exposes a preconfigured `templatePackage` as a perSystem module argument,
# so individual package modules don't each have to know how to construct
# it from `_lib/templatePackage`.
{
  perSystem =
    { pkgs, ... }:
    {
      _module.args.templatePackage = import ../_lib/templatePackage {
        basePkgs.nix = pkgs;
        inherit (pkgs.lib) attrsets;
      };
    };
}
