recursion:
{ nixpkgs, ... }:

let
  inherit (builtins)
    readDir
    readFile
  ;

  inherit (nixpkgs.lib.strings)
    hasSuffix
    removeSuffix
  ;

  inherit (nixpkgs.lib.attrsets)
    mapAttrs'
  ;

  inherit (nixpkgs.lib.filesystem)
    pathIsDirectory
    pathIsRegularFile
  ;

  imp = path: (
    if pathIsDirectory path
    then impDir path
    else impFile path
  );

  impFile = path: import path recursion;

  impDir = path: (
    if pathIsRegularFile (path + "./default.nix")
    then impFile
    else mapAttrs' (impRecursive path) (readDir path)
  );

  impRecursive = path: name: ftype: (
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

in imp
