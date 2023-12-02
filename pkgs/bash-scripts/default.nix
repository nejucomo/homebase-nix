homebase:
let
  inherit (builtins) readDir attrNames;
  inherit (homebase.nixpkgs) bash symlinkJoin writeScriptBin;
  inherit (homebase.nixpkgs.lib.attrsets) filterAttrs;
  inherit (homebase.nixpkgs.lib.strings) hasSuffix;

  remove-suffix =
    let
      inherit (builtins) stringLength substring;
    in
      suffix: s:
        assert hasSuffix suffix s;
        substring 0 (sub (stringLength s) (stringLength suffix)) s;

  shell-suffix = ".bash";

  script-names =
    let
      is-script = n: v: v == "regular" && hasSuffix shell-suffix n;
    in
      attrNames (filterAttrs is-script (readDir ./scripts));

  mk-wrapper = name: writeScriptBin (remove-suffix shell-suffix name) ''
    #! ${bash}/bin/bash
    source '${./prelude.bash}'
    source '${./scripts}/${name}'
    source '${./postlude.bash}'
  '';
in
  symlinkJoin {
    name = "bash-scripts";
    paths = map mk-wrapper script-names;
  }
