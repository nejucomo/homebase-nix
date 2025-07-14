lib:
{ unfreePackages }:
system:

let
  inherit (builtins) mapAttrs trace;
  inherit (lib) flakeInputs;
  inherit (flakeInputs) nixpkgs;

  otherFlakes = removeAttrs flakeInputs [
    "self"
    "nixpkgs"
  ];

  selectDefaultPkg =
    name: flake:
    (trace "selecting default package for flake input: ${name}" flake.packages."${system}".default);

  syslib = lib.extend {
    basePkgs = {
      nix = import nixpkgs {
        inherit system;

        config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) unfreePackages;
      };

      flakes = mapAttrs selectDefaultPkg otherFlakes;
    };

    templatePackage = syslib.imp ./templatePackage;
    symlinkSplice = syslib.imp ./symlinkSplice;
  };

in
syslib
