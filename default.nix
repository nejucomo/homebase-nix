let
  nixpkgs = import <nixpkgs> {};

  pname = builtins.baseNameOf ./.;
  version = "0.1";
  name = "${pname}-${version}";

  pkgsVanilla = with nixpkgs; [
    tmux
  ];

  wrapBin = import ./wrapBin.nix;
  hlwmWrapped = wrapBin {
    pkg = "herbstluftwm";
    wrapArgs = [ "--autostart" "${./config/herbstluftwm-autostart}" ];
  };
  pkgsWrapped = [
    hlwmWrapped
    (wrapBin {
      pkg = "vim";
      wrapArgs = [ "-u" "${./config/vimrc}" ];
    })
  ];

  inherit (nixpkgs) writeScriptBin;
  startxWrapper =
    # Override startx with a hard-coded mutable path for system startx:
    writeScriptBin "startx" ''
      #!/bin/sh
      exec /run/current-system/sw/bin/startx ${hlwmWrapped}/bin/herbstluftwm "$@"
    '';

  pkgsOther = [
    startxWrapper
  ];

  paths = pkgsVanilla ++ pkgsWrapped ++ pkgsOther;
in
  nixpkgs.symlinkJoin {
    inherit name paths;
  }
