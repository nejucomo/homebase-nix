let
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

  importPkg = import ./pkglib.nix baseDir;
in
  map importPkg pkgNames
