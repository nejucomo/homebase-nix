{ nixpkgs }:
let
  homebase = rec {
    inherit nixpkgs;

    ## Import the argument, passing in the closure of homebase:
    imp = mod-path: import mod-path homebase;

    custom-pkgs = imp ./custom-pkgs;
  };
in
  homebase
