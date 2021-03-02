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

          wrapBin = { pkg, wrapArgs, binName ? null }:
            let
              bname = if binName == null then pkg else binName;
              realpkg = nixpkgs.${pkg};
              realbin = "${realpkg}/bin/${bname}";

              pkgOverride = nixpkgs.writeScriptBin bname ''
                #!/bin/sh
                exec "${realbin}" ${toString wrapArgs} "$@"
              '';
            in
              nixpkgs.symlinkJoin {
                name = pname;
                paths = [ pkgOverride realpkg ];
              };

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
