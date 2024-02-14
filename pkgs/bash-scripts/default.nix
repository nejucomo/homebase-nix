homebase:
let
  inherit (builtins) readDir attrNames;
  inherit (homebase.nixpkgs) bash symlinkJoin writeScriptBin stdenvNoCC;
  inherit (homebase.nixpkgs.lib.attrsets) filterAttrs;
  inherit (homebase.nixpkgs.lib.strings) hasSuffix;

  remove-suffix =
    let
      inherit (builtins) stringLength substring;
    in
      suffix: s:
        assert hasSuffix suffix s;
        substring 0 ((stringLength s) - (stringLength suffix)) s;

  shell-suffix = ".bash";

  script-names =
    let
      is-script = n: v: v == "regular" && hasSuffix shell-suffix n;
    in
      attrNames (filterAttrs is-script (readDir ./scripts));

  mk-wrapper = name: writeScriptBin (remove-suffix shell-suffix name) ''
    #! ${bash}/bin/bash
    source '${./scripts}/${name}'
    source '${./postlude.bash}'
  '';

  wrapped-pkg = symlinkJoin {
    name = "bash-script-wrappers";
    paths = map mk-wrapper script-names;
  };
in
  # Ref: https://msfjarvis.dev/posts/writing-your-own-nix-flake-checks/
  stdenvNoCC.mkDerivation {
    name = "bash-scripts";
    buildInputs = [ wrapped-pkg ];
    src = ./.;

    # Forward `wrapped-pkg` to the output:
    buildPhase = ''
      mkdir "$out"
      cp -av '${wrapped-pkg.out}'/* "$out"
    '';

    # Checks:
    doCheck = true;
    checkPhase = ''
      selftest='${wrapped-pkg}/bin/postlude-bash-test'
      ls -l "$selftest"
      exec "$selftest"
    '';
  }
