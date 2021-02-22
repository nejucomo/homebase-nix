let
  nixpkgs = import <nixpkgs> {};

  pname = builtins.baseNameOf ./.;
  version = "0.1";
  name = "${pname}-${version}";

  pkgsVanilla = with nixpkgs; [
    alacritty
    tmux
  ];

  wrapBin = import ./wrapBin.nix;
  pkgsWrapped = [
    (wrapBin {
      pkg = "vim";
      wrapArgs = [ "-u" "${./config/vimrc}" ];
    })
    (wrapBin {
      pkg = "herbstluftwm";
      wrapArgs = [ "--autostart" "${./config/herbstluftwm-autostart}" ];
    })
  ];

  inherit (nixpkgs) writeScriptBin;
  startxWrapper =
    # Override startx with a hard-coded mutable path for system startx:
    writeScriptBin "startx" ''
      #!/bin/sh
      exec /run/current-system/sw/bin/startx herbstluftwm "$@"
    '';

  pkgsOther = [
    startxWrapper
  ];

  paths = pkgsVanilla ++ pkgsWrapped ++ pkgsOther;
in
  nixpkgs.symlinkJoin {
    inherit name paths;
  }
