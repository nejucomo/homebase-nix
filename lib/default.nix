/*
  A function mapping a packages dir to a list of derivations defining
  the user environment.

  Pseudo type signature: `pkgsDir -> [ derivation ]`

  The `pkgsDir` must be a directory with a "base.nix" and zero or more
  "custom package directories".

  The "base.nix" must evaluate to a list of derivations which are
  included in the final result as-is. The typical body just returns a
  list of uncustomized nixpkgs, for example:

    let nixpkgs = import <nixpkgs> {};
    in [ nixpkgs.less, nixpkgs.gnugrep ]

  Each custom package directory must have a `default.nix` (so the
  directory can be imported) which provides a function matching the
  `./import-pkg.nix` interface.
*/

let
  inherit (builtins) attrNames readDir;
  nixpkgs = import <nixpkgs> {};

  inherit (nixpkgs.lib.attrsets) filterAttrs;
  mkImportPkg = import ./import-pkg.nix;
in
  pkgsDir:
    let
      basePkgs = import (pkgsDir + "/base.nix");

      customPkgs =
        let
          dirEntries = readDir pkgsDir;
          dirs =
            let
              isDir = _: v: v == "directory";
            in
              filterAttrs isDir dirEntries;

          pkgNames = attrNames dirs;

          importPkg = mkImportPkg pkgsDir;
        in
          map importPkg pkgNames;
    in
      basePkgs ++ customPkgs
