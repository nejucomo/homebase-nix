let
  nixpkgs = import <nixpkgs> {};

  pname = builtins.baseNameOf ./.;
  version = "0.1";

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
in
  nixpkgs.symlinkJoin {
    name = "${pname}-0.1";
    paths = pkgsVanilla ++ pkgsWrapped;
  }
