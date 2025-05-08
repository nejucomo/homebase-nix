flakeInputs @ { nixpkgs, ... }:
let
  inherit (nixpkgs)
    symlinkJoin
  ;

  # Combine all of the outputs of a package into a single output pkg. For
  # example, many nixpkgs pkgs have a separate output for manpages. This
  # ensures if we select the base package (example: `nixpkgs.jq`) we also
  # get the manpages.
  allOutputs = pkg: symlinkJoin {
    name = "allOutputs-${pkg.name}";
    paths = map (attr: pkg."${attr}") pkg.outputs;
  };

  recursion = rec {
    inherit flakeInputs, nixpkgs;

    # defineHomebase :: { Name: Deriv } -> Deriv
    defineHomebase = pkgs: symlinkJoin {
      name = "homebase-nix";
      paths = map allOutputs (attrVals pkgs);
    }

    # imp :: Path -> Any
    #
    # Import a path passing this lib:
    imp = path: (
      let
        inherit (builtins)
          readDir
        ;

        inherit (nixpkgs.strings)
          hasSuffix
          removeSuffix
        ;

        inherit (nixpkgs.sources)
          pathIsDirectory
          pathIsRegularFile
        ;

        impFile = import path recursion;

        impDir = (
          if pathIsRegularFile (path + "./default.nix")
          then impFile
          else mapAttrs' impRecursive (readDir path)
        );

        impRecursive = name: ftype: (
          let subpath = path + "/${name}";
          in if hasSuffix ".nix" name || ftype == "directory"
          then {
            name = removeSuffix ".nix" name;
            value = imp subpath;
          } else {
            inherit name;
            value = readFile subpath;
          }
        );

      in if pathIsDirectory path
      then impDir
      else impFile
    );
  };

in recursion
