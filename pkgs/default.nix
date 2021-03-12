let
  basePkgs = import ./base.nix;

  inherit (builtins) attrNames readDir;

  nixpkgs = import <nixpkgs> {};
  inherit (nixpkgs.lib.attrsets) filterAttrs;

  baseDir = ./.;
  dirEntries = readDir baseDir;
  dirs =
    let
      isDir = _: v: v == "directory";
    in
      filterAttrs isDir dirEntries;

  pkgNames = attrNames dirs;

  importPkg = import ./lib.nix baseDir;
  customPkgs = map importPkg pkgNames;
in
  basePkgs ++ customPkgs
