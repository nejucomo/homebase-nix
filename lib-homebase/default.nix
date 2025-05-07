nixpkgs:
let
  inherit (nixpkgs) lib symlinkJoin writeShellScriptBin;

  tracex = expr: builtins.trace expr expr;

  # Combine all of the outputs of a package into a single output pkg. For
  # example, many nixpkgs pkgs have a separate output for manpages. This
  # ensures if we select the base package (example: `nixpkgs.jq`) we also
  # get the manpages.
  all-outputs = pkg: symlinkJoin {
    name = "all-outputs-${pkg.name}";
    paths = map (attr: pkg."${attr}") pkg.outputs;
  };

  shell-suffix = ".bash";
in rec {
  define-user-environment = base-pkgs: specs:
    let
      resolve-dependencies = import ./resolve-dependencies.nix nixpkgs;
      resolved = resolve-dependencies base-pkgs specs;

      inherit (resolved) user-environment;
      inherit (builtins) attrValues;
    in
      symlinkJoin {
        name = "homebase-user-environment";
        paths = map all-outputs (attrValues user-environment);
      };

  override-bin = upstream-bin: mk-script: (
    let
      inherit (builtins) baseNameOf;
      inherit (nixpkgs) runCommand;

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

  package-bash-scripts = (
    let
      inherit (builtins) baseNameOf readDir attrNames;
      inherit (lib.attrsets) filterAttrs;
      inherit (lib.strings) hasSuffix;

      is-script = n: v: v == "regular" && hasSuffix shell-suffix n;

      scripts-in = dirpath: map (n: dirpath + ("/" + n)) (scriptnames-in dirpath);

      scriptnames-in = dirpath: attrNames (filterAttrs is-script (readDir dirpath));
    in dirpath: symlinkJoin {
      name = baseNameOf dirpath;
      paths = map package-bash-script (scripts-in dirpath);
    }
  );

  package-bash-script = (
    let
      postlude = ../pkgs/bash-postlude/postlude.bash;

      inherit (lib.strings) hasSuffix;

      remove-suffix =
        let
          inherit (builtins) stringLength substring;
        in
          suffix: s:
            assert hasSuffix suffix s;
            substring 0 ((stringLength s) - (stringLength suffix)) s;

    in path: writeShellScriptBin (remove-suffix shell-suffix (baseNameOf path)) ''
      source '${path}'
      source '${postlude}'
    ''
  );
}
