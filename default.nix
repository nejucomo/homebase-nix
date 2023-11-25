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

    bash = homebase.wrap-bins homebase.nixpkgs.bashInteractive {
      bash = { upstream-bin, ... }: ''
        #! ${upstream-bin}
        exec "${upstream-bin}" "--rcfile" "${./pkgs/bash/bashlib}/bashrc" "$@"
      '';
    };

    dunst = homebase.wrap-bins homebase.nixpkgs.dunst {
      dunst = { upstream-bin, ... }: ''
        #!/bin/sh
        exec "${upstream-bin}" -conf "${./pkgs/dunst/dunst.conf}" "$@"
      '';
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
