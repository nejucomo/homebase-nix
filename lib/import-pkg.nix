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

imparams@{ nixpkgs }:
pkgsDir:
  let
    repoName = baseNameOf pkgsDir;
    importPkg = pkgName:
      let
        pkgDir = pkgsDir + "/${pkgName}";
        pname = "${repoName}-${pkgName}";
        version = "0.1"; # TODO FIXME
        name = "${pname}-${version}";

        pkglib = {
          inherit nixpkgs importPkg pkgName pname version name;

          xdgWrapper = { xdgAppName ? pkgName, binsToWrap ? [ pkgName ] }:
            let
              xdgpname = "${pname}-xdg-conf";
              xdgconf = nixpkgs.stdenv.mkDerivation {
                pname = xdgpname;
                inherit version;

                src = pkgDir + "/xdg";
                builder = nixpkgs.writeScript "${xdgpname}-builder.sh" ''
                  source "$stdenv/setup"
                  mkdir "$out"
                  outsub="$out/${xdgAppName}"
                  cp -a "$src" "$outsub"
                  chmod -R u+w "$outsub"
                  patchShebangs "$outsub"
                '';
              };
              wrapBin = { realbin, ... }: ''
                #!/bin/sh
                export XDG_CONFIG_HOME="${xdgconf}"
                exec "${realbin}" "$@"
              '';
              mkWrapBinPair = name: {
                inherit name;
                value = wrapBin;
              };
              binCallbacksPairs = map mkWrapBinPair binsToWrap; 
              binCallbacks = builtins.listToAttrs binCallbacksPairs;
            in
              pkglib.wrapBins binCallbacks;

          wrapBins = binCallbacks:
            let
              realpkg = nixpkgs.${pkgName};
              wrapBin = binName: wrapBin:
                let
                  realbin = "${realpkg}/bin/${binName}";
                  wrappedBody = wrapBin { inherit realpkg realbin; };
                in
                  nixpkgs.writeScriptBin binName wrappedBody;

              inherit (builtins) attrValues mapAttrs;
              wrappers = attrValues (mapAttrs wrapBin binCallbacks);
              upstreams =
                let
                  inherit (builtins) attrNames;

                  mkUpstream = binName: nixpkgs.runCommand "upstream-${binName}-${realpkg.name}" {} ''
                    mkdir -p "$out/bin";
                    ln -s "${realpkg}/bin/${binName}" "$out/bin/upstream-${binName}"
                  '';
                in
                  map mkUpstream (attrNames binCallbacks);
            in
              nixpkgs.symlinkJoin {
                name = pname;
                paths = wrappers ++ upstreams ++ [ realpkg ];
              };

          # TODO: rename this and remove `scriptName` which is always `pkgName` in every existing case.
          pkgScript = text:
            let
              inherit (nixpkgs) stdenv writeScript;
            in
              stdenv.mkDerivation {
                inherit pname version;

                src = writeScript pkgName text;
                builder = writeScript "${pname}-builder.sh" ''
                  source "$stdenv/setup"
                  mkdir -p "$out/bin"
                  install -m 755 "$src" "$out/bin/${pkgName}"
                  patchShebangs "$out/bin"
                '';
              };
        };

        makePkg = import pkgDir;
      in
        makePkg pkglib;
  in
    importPkg
