/*
  Module provides the interface to define "custom packages". A custom
  package is a directory with a "default.nix" which is a direct child
  of a base `pkgsDir`. The `default.nix` must evaluate to a function
  with this interface:

  `pkgParams@{ ... } -> derivation`

  The `pkgParams` attrset argument has these fields:

  {
    pname,
    # The custom package's pname (identical to its directory name).

    version,
    # Version is hard-coded for now.

    name,
    # name = "${pname}-${version}.

    nixpkgs,
    # The nixpkgs in-use by homebase.

    importPkg,
    # A function of `pkgName -> derivation` where `pkgName` names another
    # package in the `pkgsDir`. This allows custom packages to depend on
    # each other, but dependency cycles will cause an infinite recursion.

    # Plus some more utility functions that are in flux right now.
  }
*/

let
  repoName = baseNameOf ../.;
  nixpkgs = import <nixpkgs> {};

in pkgDir:
  let
    importPkg = pkgName:
      let
        pname = "${repoName}-${pkgName}";
        version = "0.1";
        name = "${pname}-${version}";

        pkglib = {
          inherit nixpkgs importPkg pkgName pname version name;

          wrapBinArgs = args@{ wrapArgs, ... }:
            let
              baseArgs = builtins.removeAttrs args ["wrapArgs"];
            in
              pkglib.wrapBinCb (baseArgs // {
                mkBinBody = {realbin, ...}: ''
                  #!/bin/sh
                  exec "${realbin}" ${toString wrapArgs} "$@"
                '';
              });

          wrapBinCb = args@{ pkg, binName ? null, mkBinBody }:
            let
              bname = if binName == null then pkg else binName;
              realpkg = nixpkgs.${pkg};
              realbin = "${realpkg}/bin/${bname}";

              binBody = mkBinBody (args // {
                inherit bname realbin realpkg;
              });

              pkgOverride = nixpkgs.writeScriptBin bname binBody;
            in
              nixpkgs.symlinkJoin {
                name = pname;
                paths = [ pkgOverride realpkg ];
              };

          # TODO: rename this and remove `scriptName` which is always `pkgName` in every existing case.
          writeScriptBin = scriptName: text:
            let
              inherit (nixpkgs) stdenv writeScript;
            in
              stdenv.mkDerivation {
                inherit pname version;

                src = writeScript scriptName text;
                builder = writeScript "${pname}-builder.sh" ''
                  source "$stdenv/setup"
                  function run { echo "Running: $*"; eval "$@"; }
                  run mkdir -p "$out/bin"
                  run install -m 755 "$src" "$out/bin/${scriptName}"
                  run patchShebangs "$out/bin"
                '';
              };
        };

        makePkg = import (pkgDir + "/${pkgName}");
      in
        makePkg pkglib;
  in
    importPkg
