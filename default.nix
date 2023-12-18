imparams@{ nixpkgs, git-clone-canonical, cargo-checkmate }:
let
  homebase = import ./lib-homebase {
    inherit nixpkgs;
    pname = "homebase";
    version = "0.1";
  };

  # We use foldl' to build up successively larger attrsets of packages
  # in a way that they can depend on earlier results. This can be done
  # without a fold using explicit names, eg 'pkgs4 = pkgs3 // { ... }`
  # This approach seems easier to read/maintain:

  pkgs = builtins.foldl' (pkgs: mk-pkgs: pkgs // (mk-pkgs pkgs)) {} [
    # Flake input packages:
    (_upstream-pkgs: {
      inherit
        git-clone-canonical
        cargo-checkmate
      ;
    })

    # Off-the-shelf nixpkgs packages:
    (_upstream-pkgs: {
      inherit (homebase.nixpkgs)
        acpi
        coreutils
        file
        findutils
        firefox
        gawk
        gcc
        gnugrep
        gnused
        gzip
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
        signal-desktop
        unclutter
        which
        xss-lock
      ;

      inherit (homebase.nixpkgs.xorg)
        xsetroot
      ;

      # Necessary for meld:
      inherit (homebase.nixpkgs.gnome3)
        adwaita-icon-theme
      ;

      dunst-man = homebase.nixpkgs.dunst.man;
      herbstluftwm-man = homebase.nixpkgs.herbstluftwm.man;
    })

    # Local packages defined in this repo:
    (_upstream-pkgs: {
      bash-scripts = homebase.imp ./pkgs/bash-scripts;
    })

    # These are packages which we supply custom config args to in wrappers:
    (_upstream-pkgs:
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
        } // {
          helix = homebase.wrap-configs homebase.nixpkgs.helix {
            hx = ''--config '${./pkgs/helix/config.toml}' '';
          };

          git = homebase.wrap-xdg-config homebase.nixpkgs.git ./pkgs/git-xdg [ "git" ];
        }
    )

    # Customized packages with intra-package dependencies:
    (upstream-pkgs: rec {
      herbstluftwm = homebase.imp ./pkgs/wm {
        inherit (upstream-pkgs)
          alacritty
          bash
          bash-scripts
          dunst
          firefox
          i3lock
          polybar # Note: this has non-explicit dependency on `touchpad`
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
    })
  ];

  all-pkgs = homebase.include-extras (builtins.attrValues pkgs);
in
  homebase.nixpkgs.symlinkJoin {
    name = "${homebase.pname}-${homebase.version}";
    paths = all-pkgs;
  }
