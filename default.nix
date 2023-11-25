imparams@{ nixpkgs }:
let
  pname = baseNameOf ./.;
  version = "0.1";

  homebase = import ./lib imparams;
in
  nixpkgs.symlinkJoin {
    name = "${pname}-${version}";
    paths = homebase.custom-pkgs ./pkgs;
  }
