flakeInputs @ { nixpkgs, ... }:
let
  nixlib = nixpkgs.lib;

  self = nixlib // rec {
    inherit flakeInputs;

    imp = path: import path self;

    defineHomebase = imp ./defineHomebase.nix;
    mergeStrict = imp ./mergeStrict.nix;
    basePackagesForSystem = imp ./basePackagesForSystem.nix;
    templatePackage = imp ./templatePackage;
  };

in self
