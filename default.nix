imparams@{ nixpkgs, git-clone-canonical, cargo-checkmate }:
let
  homebase = import ./lib-homebase {
    inherit nixpkgs;
    pname = "homebase";
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

  pkgs = rec {
    inherit
      git-clone-canonical
      cargo-checkmate
    ;

    inherit (config-pkgs)
      bash
      alacritty
      dunst
      polybar
      tmux
      vim
    ;

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
      magic-wormhole
      man
      meld
      nix
      libnotify
      ps
      pstree
      ripgrep
      rustup
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

    herbstluftwm = homebase.imp ./pkgs/wm {
      inherit
        alacritty
        bash
        dunst
        firefox
        i3lock
        polybar
        tmux
        unclutter
        xsetroot
        xss-lock
      ;
    };

    startx =
      let
        # Hard-coded external dependency:
        systemStartx = "/run/current-system/sw/bin/startx";
      in
        homebase.nixpkgs.writeScriptBin "startx" ''
          exec "${systemStartx}" "${herbstluftwm}/bin/herbstluftwm" "$@"
        '';

    bash-scripts = homebase.imp ./pkgs/bash-scripts;
  };

  all-pkgs = homebase.include-extras (builtins.attrValues pkgs);
in
  homebase.nixpkgs.symlinkJoin {
    name = "${homebase.pname}-${homebase.version}";
    paths = all-pkgs;
  }
