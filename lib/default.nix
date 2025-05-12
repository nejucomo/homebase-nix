flakeInputs @ { nixpkgs, ... }:
let
  inherit (nixpkgs)
    symlinkJoin
  ;

  recursion = {
    inherit flakeInputs nixpkgs;

    # defineHomebase :: { Name: Deriv } -> Deriv
    defineHomebase = import ./defineHomebase.nix flakeInputs;

    # imp :: Path -> Any
    #
    # Import a path passing this lib:
    imp = import ./imp.nix recursion flakeInputs;
  };

in recursion
