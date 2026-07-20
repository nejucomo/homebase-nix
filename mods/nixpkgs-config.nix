# Configure the `pkgs` argument given to every `perSystem` module
# to enable specific unfree packages.
{ lib, inputs, ... }:
let
  unfreePkgs = [ "claude-code" ];

  inherit (builtins) elem;
  inherit (lib) getName;
in
{
  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfreePredicate = pkg: elem (getName pkg) unfreePkgs;
      };
    };
}
