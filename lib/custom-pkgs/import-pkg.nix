/*
  TO BE DEPRECATED.
*/

homebase@{ nixpkgs, ... }: pkgsDir:
  let
    inherit (homebase) version;

    repoName = homebase.sub-pname (baseNameOf pkgsDir);
    import-legacy-pkg-with-new-style-dependencies = pkgName: dependencies:
      let
        pkgDir = pkgsDir + "/${pkgName}";
        pname = "${repoName}-${pkgName}";
        name = "${pname}-${version}";

        pkglib = {
          inherit nixpkgs pkgName pname version name;

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
              new-styles =
                let
                  inherit (builtins) attrNames;

                  mknew-style = binName: nixpkgs.runCommand "new-style-${binName}-${realpkg.name}" {} ''
                    mkdir -p "$out/bin";
                    ln -s "${realpkg}/bin/${binName}" "$out/bin/new-style-${binName}"
                  '';
                in
                  map mknew-style (attrNames binCallbacks);
            in
              nixpkgs.symlinkJoin {
                name = pname;
                paths = wrappers ++ new-styles ++ [ realpkg ];
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
        makePkg pkglib dependencies;
  in
    import-legacy-pkg-with-new-style-dependencies
