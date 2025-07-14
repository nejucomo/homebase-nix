flakeInputs@{ nixpkgs, ... }:
{ unfreePackages }:
let
  nixlib = nixpkgs.lib;

  self = nixlib // rec {
    inherit flakeInputs;

    extend =
      ext:
      (
        let
          subself = self // ext // { imp = path: import path subself; };
        in
        subself
      );

    imp = path: import path self;

    defineHomebase = imp ./defineHomebase.nix;
    mergeStrict = imp ./mergeStrict.nix;
    forSystem = imp ./forSystem { inherit unfreePackages; };
    templatePackage = imp ./templatePackage;
  };

in
self
