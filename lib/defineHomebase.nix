# lib.defineHomebase :: [System] -> (System -> { Name -> Derive}) -> Deriv
lib:
supportedSystems:

# p4s :: System -> [Deriv]
p4s:

let
  defaultForSystem = system: (
    let
      inherit (lib.forSystem system) basePkgs symlinkSplice;
      inherit (basePkgs.nix) symlinkJoin;

      pkgs = p4s system;

      # Combine all of the outputs of a package into a single output pkg. For
      # example, many nixpkgs pkgs have a separate output for manpages. This
      # ensures if we select the base package (example: `nixpkgs.jq`) we also
      # get the manpages.
      allOutputs = pkg: (
        let
          inherit (builtins) trace toJSON;
          msg =  "selecting ${pkg.name} - outputs: ${toJSON pkg.outputs}";

        in trace msg symlinkJoin {
          name = "allOutputs-${pkg.name}";
          paths = map (attr: pkg."${attr}") pkg.outputs;
        }
      );

    in {
      ${system}.default = symlinkSplice {
        name = "homebase-nix_${system}";
        roots = map allOutputs pkgs;
      };
    }
  );

  inherit (lib.lists) forEach;
  defaults = lib.lists.forEach supportedSystems defaultForSystem;

in {
  packages = lib.mergeStrict.list defaults;
}
