let
  nixpkgs = import <nixpkgs> {};

  pname = builtins.baseNameOf ./.;
  vim = import ./wrapped-vim;
in
  nixpkgs.symlinkJoin {
    name = "${pname}-0.1";
    paths = [
      nixpkgs.tmux
      vim
    ];
  }
