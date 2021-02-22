let
  nixpkgs = import <nixpkgs> {};
  inherit (nixpkgs) writeScript;
in
  { pkg, wrapArgs }:
    let
      name = "homebase-${pkg}";
      realpkg = nixpkgs.${pkg};
      realbin = "${realpkg}/bin/${pkg}";
      wrapbin = writeScript "${name}" ''
        #! /bin/bash
        exec "${realbin}" ${toString wrapArgs} "$@"
      ''; 
    in
      nixpkgs.stdenv.mkDerivation {
        inherit name;
        src = wrapbin;
        builder = writeScript "${name}-builder.sh" ''
          source "$stdenv/setup"
          mkdir -p "$out/bin"
          install -m 555 "$src" "$out/bin/${pkg}"
          chmod -R u+w "$out"
          patchShebangs "$out"
          ln -s "${realbin}" "$out/bin/${pkg}-unwrapped"
        '';
      }
