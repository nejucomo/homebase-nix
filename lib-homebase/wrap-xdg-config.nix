homebase:
upstream-pkg: xdg-config-dir: upstream-bins:
let
  inherit (homebase.nixpkgs) stdenv writeScript;

  xdg-name = upstream-pkg.pname;
  xdg-pname = "${xdg-name}-xdg-conf";
  xdg-config-pkg = stdenv.mkDerivation {
    pname = xdg-pname;
    inherit (homebase) version;

    src = xdg-config-dir;
    builder = writeScript "${xdg-pname}-builder.sh" ''
      source "$stdenv/setup"
      mkdir "$out"
      outsub="$out/${xdg-name}"
      cp -a "$src" "$outsub"
      chmod -R u+w "$outsub"
      patchShebangs "$outsub"
    '';
  };
  wrap-bin-kvpair = name: {
    inherit name;
    value = { upstream-bin, ... }: ''
      #!/bin/sh
      export XDG_CONFIG_HOME='${xdg-config-pkg}'
      exec '${upstream-bin}' "$@"
    '';
  };

  bin-wrapper-set = builtins.listToAttrs (map wrap-bin-kvpair upstream-bins);
in
  homebase.wrap-bins upstream-pkg bin-wrapper-set
