syslib:
{ name, roots }:
let
  inherit (builtins)
    readFile
  ;

  inherit (syslib.strings)
    concatStringsSep
  ;
    
  inherit (syslib.basePkgs.nix)
    ripgrep
    runCommand
  ;

  env = {
    buildInputs = [
      ripgrep
    ];
    roots = concatStringsSep ":" roots;
  };

  builder = readFile ./builder.sh;

in runCommand name env builder
