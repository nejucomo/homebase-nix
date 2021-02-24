let
  inherit (import <nixpkgs> {}) symlinkJoin;

  pname = builtins.baseNameOf ./.;
  version = "0.1";
in
  symlinkJoin {
    name = "${pname}-${version}";
    paths = import ./pkgs;
  }
