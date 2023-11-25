{ nixpkgs, pname, version }:
let
  homebase = rec {
    inherit nixpkgs pname version;

    ## Name a sub-package
    sub-pname = subname: "${pname}-${subname}";

    ## Import the argument, passing in the closure of homebase:
    imp = mod-path: import mod-path homebase;

    ## Legacy custom-pkgs importer (to be deprecated):
    legacy-custom-pkgs = imp ./custom-pkgs;

    ## Include extras for the given pacakges, such as man pages:
    include-extras = pkgs:
      let
        inherit (nixpkgs.lib.lists) flatten;

        include-optional-man =  pkg:
          if pkg ? man
          then [pkg pkg.man]
          else [pkg];
      in
        flatten (map include-optional-man pkgs);

    ## Wrap binaries from an underlying package:
    wrap-bins = upstream-pkg: bin-wrappers:
      let
        inherit (nixpkgs) symlinkJoin runCommand writeScriptBin;
        inherit (nixpkgs.lib.attrsets) mapAttrs;

        upstream-name = upstream-pkg.name;

        wrap-bin = bin-name: cb:
          let
            wrapper-pkg-name = sub-pname "wrapped-${upstream-name}-${bin-name}";
            upstream-bin = "${upstream-pkg}/bin/${bin-name}";

            wrapped-bin = writeScriptBin bin-name (cb {
              inherit upstream-pkg upstream-bin;
            });

            linked-bin = runCommand "${wrapper-pkg-name}-uplink" {} ''
              mkdir -vp "$out/bin"
              ln -s '${upstream-bin}' "$out/bin/upstream-${bin-name}"
            '';
          in
            symlinkJoin {
              name = wrapper-pkg-name;
              paths = [ wrapped-bin linked-bin ];
            };

        bin-pkgs = mapAttrs wrap-bin bin-wrappers;
      in
        symlinkJoin {
          name = sub-pname "wrapped-${upstream-name}";
          paths = builtins.attrValues bin-pkgs;
        };
  };
in
  homebase
