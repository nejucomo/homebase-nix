let
  nixpkgs = import <nixpkgs> {};

  pname = builtins.baseNameOf ./.;
in
  nixpkgs.symlinkJoin {
    name = "${pname}-0.1";
    paths = with nixpkgs; [
      tmux
      vim
    ];
  }
