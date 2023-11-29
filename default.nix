imparams@{ nixpkgs }:
let
  homebase = import ./lib-homebase {
    inherit nixpkgs;
    pname = baseNameOf ./.;
    version = "0.1";
  };

  config-pkgs =
    let
      upstream-pkgs = homebase.nixpkgs // {
        bash = homebase.nixpkgs.bashInteractive;
      };
    in
      homebase.wrap-config-pkgs upstream-pkgs {
        bash = ''--rcfile '${./pkgs/bash/bashlib}/bashrc' '';
        alacritty = ''--config-file '${./pkgs/alacritty/alacritty.yml}' '';
        dunst = ''-config '${./pkgs/dunst/dunst.conf}' '';
        polybar = ''--config='${./pkgs/polybar/config.ini}' '';
        tmux = ''-f '${./pkgs/tmux/tmux.conf}' '';
        vim = ''-u '${./pkgs/vim/vimrc}' '';
      };

  pkgs = {
    inherit (homebase.nixpkgs)
      acpi
      coreutils
      findutils
      firefox
      gawk
      gnugrep
      gnused
      gzip
      helix
      i3lock
      killall
      less
      man
      meld
      nix
      libnotify
      ps
      pstree
      ripgrep
      unclutter
      which
      xss-lock
    ;

    inherit (homebase.nixpkgs.xorg)
      xsetroot
    ;

    dunst-man = homebase.nixpkgs.dunst.man;
    herbstluftwm-man = homebase.nixpkgs.herbstluftwm.man;

    git = homebase.wrap-xdg-config homebase.nixpkgs.git ./pkgs/git-xdg [ "git" ];
  }
  // config-pkgs;

  pkgs-legacy = homebase.legacy-custom-pkgs ./legacy-pkgs pkgs;

  all-pkgs-without-extras = pkgs // pkgs-legacy;

  all-pkgs = homebase.include-extras (builtins.attrValues all-pkgs-without-extras);
in
  homebase.nixpkgs.symlinkJoin {
    name = "${homebase.pname}-${homebase.version}";
    paths = all-pkgs;
  }
