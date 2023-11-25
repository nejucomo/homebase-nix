imparams@{ nixpkgs }:
let
  pname = baseNameOf ./.;
  version = "0.1";

  mkPkgs = import ./lib imparams;
in
  nixpkgs.symlinkJoin {
    name = "${pname}-${version}";
    paths = mkPkgs ./pkgs;
  }
