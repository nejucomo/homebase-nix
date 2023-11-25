{ nixpkgs, pname, version }:
let
  homebase = rec {
    inherit nixpkgs pname version;

    ## Name a sub-package
    sub-pname = subname: "${pname}-${subname}";

    ## Import the argument, passing in the closure of homebase:
    imp = mod-path: import mod-path homebase;

    ## Legacy custom-pkgs importer (to be deprecated):
    custom-pkgs = imp ./custom-pkgs;

    ## Include extras for the given pacakges, such as man pages:
    include-extras = pkgs:
      let
        inherit (nixpkgs.lib.lists) flatten;

        include-optional-man =  pkg:
          if pkg ? man
          then [pkg pkg.man]
          else [pkg];
      in
        flatten (map include-optional-man pkgs);
  };
in
  homebase
