let
  inherit (builtins) attrNames readDir;

  nixpkgs = import <nixpkgs> {};
  inherit (nixpkgs.attrsets) filterAttrs;

  baseDir = ./.;
  dirEntries = readDir baseDir;
  dirs =
    let
      isDir = _: v: v == "directory";
    in
      filterAttrs isDir dirEntries;

  pkgNames = attrNames dirs;

  pkglib = import ./pkglib.nix;
  impPkg = n:
    let
      mkPkg = import (basedir + "/${n}");
    in
      mkPkg pkglib;
in
  map impPkg pkgNames;
