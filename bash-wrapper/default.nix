## Wrap bash so that it loads our baked-in rcfile
homebase:
let
  ## Package metadata
  pname = homebase.sub-pname "wrapped-bash";
  inherit (homebase) version;

  ## Package definition
  inherit (homebase.nixpkgs) bashInteractive symlinkJoin writeScriptBin;

  upstream-bash-bin = "${bashInteractive}/bin/bash";

  pkg-wrapped-bash = writeScriptBin "bash" ''
    #! ${upstream-bash-bin}
    exec "${upstream-bash-bin}" "--rcfile" "${./bashlib}/bashrc" "$@"
  '';

  pkg-upstream-bash =  homebase.nixpkgs.runCommand "${pname}-upstream-link" {} ''
    mkdir -vp "$out/bin"
    ln -s '${upstream-bash-bin}' "$out/bin/upstream-bash"
  '';

in
  symlinkJoin {
    name = "${pname}-${version}";
    paths = [
      pkg-upstream-bash
      pkg-wrapped-bash
    ];
  }
