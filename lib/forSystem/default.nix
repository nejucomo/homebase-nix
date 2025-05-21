lib:
system:

let
  inherit (builtins) mapAttrs trace;
  inherit (lib) flakeInputs;
  inherit (flakeInputs) nixpkgs;

  otherFlakes = removeAttrs flakeInputs ["self" "nixpkgs"];

  selectDefaultPkg = name: flake: (
    trace "selecting default package for flake input: ${name}"
    flake.packages."${system}".default
  );

  syslib = lib.extend {
    basePkgs = {
      nix = nixpkgs.legacyPackages."${system}";
      flakes = mapAttrs selectDefaultPkg otherFlakes;
    };

    templatePackage = syslib.imp ./templatePackage; 
  };

in syslib
