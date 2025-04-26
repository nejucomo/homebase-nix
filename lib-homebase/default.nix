nixpkgs:
let
  # Combine all of the outputs of a package into a single output pkg. For
  # example, many nixpkgs pkgs have a separate output for manpages. This
  # ensures if we select the base package (example: `nixpkgs.jq`) we also
  # get the manpages.
  all-outputs = pkg: nixpkgs.symlinkJoin {
    name = "all-outputs-${pkg.name}";
    paths = map (attr: pkg."${attr}") pkg.outputs;
  };
in {
  symlink-join = name: paths: nixpkgs.symlinkJoin {
    inherit name paths;
  };
  
  # New API:
  define-user-environment = base-pkgs: specs:
    let
      resolve-dependencies = import ./resolve-dependencies.nix nixpkgs;
      resolved = resolve-dependencies base-pkgs specs;
      inherit (resolved) user-environment;
      inherit (builtins) attrValues;
      inherit (nixpkgs) symlinkJoin;
    in
      symlinkJoin {
        name = "homebase-user-environment";
        paths = map all-outputs (attrValues user-environment);
      };

  override-bin = upstream-bin: mk-script: (
    let
      inherit (builtins) baseNameOf;
      inherit (nixpkgs) runCommand symlinkJoin writeShellScriptBin;

      script-name = baseNameOf upstream-bin;
      pkg-name = "override-${script-name}";

      wrapped-bin = writeShellScriptBin script-name (mk-script upstream-bin);

      linked-bin = runCommand "${pkg-name}-override-link" {} ''
        mkdir -vp "$out/bin"
        ln -s '${upstream-bin}' "$out/bin/overridden-${script-name}"
      '';
    in
      symlinkJoin {
        name = pkg-name;
        paths = [ wrapped-bin linked-bin ];
      }
  );
}
