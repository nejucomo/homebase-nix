flake-inputs:
let
  homebase = import ./lib-homebase {
    inherit (flake-inputs) nixpkgs;
    pname = "homebase";
    version = "0.1";
  };

  # We use foldl' to build up successively larger attrsets of packages
  # in a way that they can depend on earlier results. This can be done
  # without a fold using explicit names, eg 'pkgs4 = pkgs3 // { ... }`
  # This approach seems easier to read/maintain:

  pkgs = builtins.foldl' (pkgs: mk-pkgs: pkgs // (mk-pkgs pkgs)) {} [
    # Flake input packages:
    (_empty-upstream-pkgs: {
      inherit (flake-inputs)
        cargo-checkmate
        leftwm
      ;

      git-clone-canonical = (
        homebase.wrap-bins
        flake-inputs.git-clone-canonical
        {
          git-clone-canonical = { upstream-bin, ... }:
            ''
            #! /usr/bin/env bash
            if [ "$#" -eq 1 ] && ! [[ "$1" =~ ^- ]]
            then
              # update links after execution:
              '${upstream-bin}' "$@" && update-hack-links
            elif [ "$#" -eq 2 ] && [ "$1" = '--show-path' ]
            then
              # Modify path:
              echo "$HOME/hack/$(basename "$('${upstream-bin}' "$@")")"
            else
              # passthru:
              exec '${upstream-bin}' "$@"
            fi
            '';
        }
      );
    })

    # Off-the-shelf nixpkgs packages:
    (_upstream-pkgs: {
      inherit (homebase.nixpkgs)
        acpi
        cargo-udeps
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
        nix-index
        libnotify
        ps
        pstree
        ripgrep
        rustup
        signal-desktop
        scrot
        unclutter
        which
        xss-lock
      ;

      inherit (homebase.nixpkgs.xorg)
        xhost
        xsetroot
      ;

      # Necessary for meld:
      inherit (homebase.nixpkgs.gnome3)
        adwaita-icon-theme
      ;

      dunst-man = homebase.nixpkgs.dunst.man;
    })

    # Local packages defined in this repo:
    (upstream-pkgs: {
      bash-scripts = homebase.imp ./pkgs/bash-scripts;
      cargo-depgraph-svg = homebase.imp ./pkgs/cargo-depgraph-svg;
      bashrc-dir = homebase.imp ./pkgs/bashrc-dir;
    })

    # bash:
    (upstream-pkgs: {
        bash = homebase.wrap-configs homebase.nixpkgs.bashInteractive {
          bash = ''--rcfile '${upstream-pkgs.bashrc-dir}/share/bashrc-dir/bashrc' '';
        };
    })

    # super hacky zellij tool:
    (upstream-pkgs: {
      # This is super ugly. How can we expose `mk-wrapper` from bash-scripts package?
      zellij-new-tab-wrapper = homebase.nixpkgs.writeScriptBin "zellij-new-tab" ''
        #! ${upstream-pkgs.bash}/bin/bash
        source '${./pkgs/bash-scripts/prelude.bash}'

        function main
        {
          parse-args 'layout=default *args' "$@"
          zellij action new-tab \
            --layout-dir '${./pkgs/zellij/confdir}/layouts' \
            --layout "$layout" \
            "''${args[@]}"
        }

        source '${./pkgs/bash-scripts/postlude.bash}'

      '';
    })

    # These are packages which we supply custom config args to in wrappers:
    (upstream-pkgs:
      homebase.wrap-config-pkgs homebase.nixpkgs {
        alacritty = ''--config-file '${./pkgs/alacritty/alacritty.toml}' '';
        dunst = ''-config '${./pkgs/dunst/dunst.conf}' '';
        polybar = ''--config='${./pkgs/polybar/config.ini}' '';
        tmux = ''-f '${./pkgs/tmux/tmux.conf}' '';
        vim = ''-u '${./pkgs/vim/vimrc}' '';
        zellij = ''--config-dir '${./pkgs/zellij/confdir}' '';
      } // {
        helix = homebase.wrap-configs homebase.nixpkgs.helix {
          hx = ''--config '${./pkgs/helix/config.toml}' '';
        };

        git = homebase.wrap-xdg-config homebase.nixpkgs.git ./pkgs/git-xdg [ "git" ];
        leftwm = homebase.wrap-xdg-config upstream-pkgs.leftwm ./pkgs/leftwm-xdg [ "leftwm" ];
      }
    )

    # Customized packages with intra-package dependencies:
    (upstream-pkgs: {
      startx =
        let
          # Hard-coded external dependency:
          systemStartx = "/run/current-system/sw/bin/startx";
        in
          homebase.nixpkgs.writeScriptBin "homebase-startx" ''
            source "${upstream-pkgs.bashrc-dir}/share/bashrc-dir/without-startx.sh"
            export RUST_LOG='leftwm=debug'
            exec "${systemStartx}" "${upstream-pkgs.leftwm}/bin/leftwm" "$@"
          '';
    })
  ];

  all-pkgs = homebase.include-extras (builtins.attrValues pkgs);
in
  homebase.nixpkgs.symlinkJoin {
    name = "${homebase.pname}-${homebase.version}";
    paths = all-pkgs;
  }
