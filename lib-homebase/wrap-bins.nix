homebase:
upstream-pkg: bin-wrappers:
let
  inherit (homebase.nixpkgs) symlinkJoin runCommand writeScriptBin;
  inherit (homebase.nixpkgs.lib.attrsets) mapAttrs;

  upstream-name = upstream-pkg.name;
  name = homebase.sub-pname "wrapped-${upstream-name}";

  wrap-bin = bin-name: cb:
    let
      wrapper-pkg-name = "${name}-${bin-name}";
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
    inherit name;
    paths = builtins.attrValues bin-pkgs;
  }

