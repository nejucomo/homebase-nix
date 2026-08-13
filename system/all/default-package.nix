# Reconstructs the old merged "everything in one profile" package that
# lib/defineHomebase.nix used to build automatically, now that every
# package is otherwise exposed individually by name. Reads config.packages
# rather than hand-maintaining a list, so it stays in sync as packages are
# added/removed elsewhere.
{
  perSystem =
    { config, pkgs, ... }:
    let
      symlinkSplice = import ../../_lib/symlinkSplice {
        basePkgs.nix = pkgs;
        strings = pkgs.lib.strings;
      };

      # Combine all of the outputs of a package into a single output pkg.
      # For example, many nixpkgs pkgs have a separate output for
      # manpages. This ensures if we select the base package we also get
      # the manpages.
      allOutputs =
        pkg:
        if builtins.length pkg.outputs == 1 then
          pkg
        else
          pkgs.symlinkJoin {
            name = "allOutputs-${pkg.name}";
            paths = map (attr: pkg.${attr}) pkg.outputs;
          };

      otherPackages = builtins.attrValues (removeAttrs config.packages [ "default" ]);
    in
    {
      packages.default = symlinkSplice {
        name = "homebase-nix";
        roots = map allOutputs otherPackages;
      };
    };
}
