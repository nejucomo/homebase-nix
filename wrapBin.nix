let
  nixpkgs = import <nixpkgs> {};
in
  { pkg, wrapArgs }:
    let
      name = "homebase-${pkg}";
      realpkg = nixpkgs.${pkg};
      realbin = "${realpkg}/bin/${pkg}";

      pkgOverride = nixpkgs.writeScriptBin pkg ''
        #! /bin/bash
        exec "${realbin}" ${toString wrapArgs} "$@"
      '';
    in
      nixpkgs.symlinkJoin {
        inherit name;
        paths = [ realpkg pkgOverride ];
      }
