/*
  A function mapping a packages dir to a list of derivations defining
  the user environment.

  Pseudo type signature: `pkgsDir -> [ derivation ]`

  The `pkgsDir` must be a directory with a "base.nix" and zero or more
  "custom package directories".

  The "base.nix" must evaluate to a list of derivations which are
  included in the final result as-is. The typical body just returns a
  list of uncustomized nixpkgs, for example:

    with nixpkgs; [ less, gnugrep ]

  Each custom package directory must have a `default.nix` (so the
  directory can be imported) which provides a function matching the
  `./import-pkg.nix` interface.
*/

homebase:
let
  inherit (builtins) attrNames readDir;

  inherit (homebase.nixpkgs.lib.attrsets) filterAttrs;
  mkImportPkg = homebase.imp ./import-pkg.nix;
in
  pkgsDir:
    let
      basePkgs = import (pkgsDir + "/base.nix") { inherit (homebase) nixpkgs; };

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
