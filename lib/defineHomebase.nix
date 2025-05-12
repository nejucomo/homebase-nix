# makeDefineHomebase :: flakeInputs -> { Name: Deriv } -> Deriv
 
{ nixpkgs, ... }:
let
  inherit (builtins)
    attrValues
  ;

  inherit (nixpkgs)
    symlinkJoin
  ;

  # Combine all of the outputs of a package into a single output pkg. For
  # example, many nixpkgs pkgs have a separate output for manpages. This
  # ensures if we select the base package (example: `nixpkgs.jq`) we also
  # get the manpages.
  allOutputs = pkg: symlinkJoin {
    name = "allOutputs-${pkg.name}";
    paths = map (attr: pkg."${attr}") pkg.outputs;
  };

# defineHomebase :: { Name: Deriv } -> Deriv
in pkgs: symlinkJoin {
  name = "homebase-nix";
  paths = map allOutputs (attrValues pkgs);
}
