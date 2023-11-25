imparams@{ nixpkgs }:
let
  homebase = import ./lib-homebase {
    inherit nixpkgs;
    pname = baseNameOf ./.;
    version = "0.1";
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

    bash = homebase.wrap-configs homebase.nixpkgs.bashInteractive {
      bash = ''--rcfile '${./pkgs/bash/bashlib}/bashrc' '';
    };

    alacritty = homebase.wrap-configs homebase.nixpkgs.alacritty {
      alacritty = ''--config-file '${./pkgs/alacritty/alacritty.yml}' '';
    };

    dunst = homebase.wrap-configs homebase.nixpkgs.dunst {
      dunst = ''-config '${./pkgs/dunst/dunst.conf}' '';
    };

    polybar = homebase.wrap-configs homebase.nixpkgs.polybarFull {
      polybar = ''--config='${./pkgs/polybar/config.ini}' '';
    };

    tmux = homebase.wrap-configs homebase.nixpkgs.tmux {
      tmux = ''-f '${./pkgs/tmux/tmux.conf}' '';
    };

    vim = homebase.wrap-configs homebase.nixpkgs.vim {
      vim = ''-u '${./pkgs/vim/vimrc}' '';
    };
  };

  pkgs-legacy = homebase.legacy-custom-pkgs ./legacy-pkgs pkgs;

  all-pkgs-without-extras = pkgs // pkgs-legacy;

  all-pkgs = homebase.include-extras (builtins.attrValues all-pkgs-without-extras);
in
  homebase.nixpkgs.symlinkJoin {
    name = "${homebase.pname}-${homebase.version}";
    paths = all-pkgs;
  }
