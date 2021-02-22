let
  nixpkgs = import <nixpkgs> {};

  pname = builtins.baseNameOf ./.;
  version = "0.1";

  wrapBin = import ./wrapBin.nix;
in
  nixpkgs.symlinkJoin {
    name = "${pname}-0.1";
    paths = [
      nixpkgs.tmux
      (wrapBin {
        pkg = "vim";
        wrapArgs = [
          "-u"
          "${./config/vimrc}"
        ];
      })
      (wrapBin {
        pkg = "herbstluftwm";
        wrapArgs = [
          "--autostart"
          "${./config/herbstluftwm-autostart}"
        ];
      })
    ];
  }
