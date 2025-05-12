## `homebase-nix/include`
#
# :: { Name: Path }
#
# These are literal paths which homebase packages may include as dependencies.

lib:

let
  inherit (builtins)
    mapAttrs
    readDir
  ;

  nameToPath = name: _: ./. + "/${name}";
  dirContents = readDir ./.;
  namesToPaths = mapAttrs nameToPath dirContents;

in namesToPaths 

  

