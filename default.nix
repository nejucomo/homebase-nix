flake-inputs:
let
  homebase = import ./lib-homebase {
    inherit (flake-inputs) nixpkgs;
    pname = "homebase";
    version = "0.1";
  };

  inherit (builtins)
    attrValues
  ;

  input-pkgs = nixpkgs // flake-inputs;

  all-new-pkgs = homebase.resolve-dependencies input-pkgs {
    user-environment = pkgs@{
      # Customized packages:
      my-alacritty
      my-bash
      my-bashrc-dir
      my-bash-scripts
      my-cargo-depgraph-svg
      my-dunst
      my-git
      my-git-clone-canonical
      my-helix
      my-leftwm
      my-polybar
      my-startx
      my-tmux
      my-vim
      my-zellij
      my-zellij-new-tab-wrapper

      # Vanilla upstream packages:
      acpi
      cargo-checkmate
      cargo-udeps
      coreutils
      dmenu
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
      leftwm
      less
      libnotify
      magic-wormhole
      man
      meld
      nix
      nix-index
      ps
      pstree
      ripgrep
      rustup
      scrot
      signal-desktop
      unclutter
      which
      xclip
      xss-lock
    }: (
      let
        inherit (builtins) attrValues;
        inherit (nixpkgs) symlinkJoin;
      in
        symlinkJoin {
          name = "${homebase.pname}-${homebase.version}";
          paths = attrValues pkgs;
        }
    );

    # Pull some stuff out of deeper nested nixpkgs:
    xhost = { xorg }: xorg.xhost;
    xsetroot = { xorg }: xorg.xsetroot;
    adwaita-icon-theme = { gnome3 }: gnome3.adwaita-icon-theme;

    my-git-clone-canonical = { git-clone-canonical }: (
      override-bin "${git-clone-canonical}/bin/git-clone-canonical" (up: ''
        if [ "$#" -eq 1 ] && ! [[ "$1" =~ ^- ]]
        then
          # update links after execution:
          '${up}' "$@" && update-hack-links
        elif [ "$#" -eq 2 ] && [ "$1" = '--show-path' ]
        then
          # Modify path:
          echo "$HOME/hack/$(basename "$('${up}' "$@")")"
        else
          # passthru:
          exec '${up}' "$@"
        fi
      ''
    );

    my-bash = { bashInteractive, my-bashrc-dir }: (
      override-bin "${bashInteractive}/bin/bash" (upstream: ''
        exec '${upstream}' \
          --rcfile '${my-bashrc-dir}/share/bashrc-dir/bashrc' \
          "$@"
      '')
    );

    my-alacritty = { alacritty }: (
      override-bin "${alacritty}/bin/alacritty" (upstream: ''
        exec '${upstream}' \
          --config-file '${./pkgs/alacritty/alacritty.toml}' \
          "$@"
      '')
    );

    my-dunst = { dunst }: (
      override-bin "${dunst}/bin/dunst" (upstream: ''
        exec '${upstream}' \
          --config-file '${./pkgs/dunst/dunst.conf}' \
          "$@"
      '')
    );

    my-polybar = { polybar }: (
      override-bin "${polybar}/bin/polybar" (upstream: ''
        exec '${upstream}' \
          --config='${./pkgs/polybar/config.ini}' \
          "$@"
      '')
    );

    my-tmux = { tmux }: (
      override-bin "${tmux}/bin/tmux" (upstream: ''
        exec '${upstream}' \
          -f '${./pkgs/tmux/tmux.conf}' \
          "$@"
      '')
    );

    my-vim = { vim }: (
      override-bin "${vim}/bin/vim" (upstream: ''
        exec '${upstream}' \
          -u '${./pkgs/vim/vimrc}' \
          "$@"
      '')
    );

    my-zellij = { zellij }: (
      override-bin "${zellij}/bin/zellij" (upstream: ''
        exec '${upstream}' \
          --config-dir '${./pkgs/zellij}/confdir' \
          "$@"
      '')
    );

    my-helix = { helix }: (
      override-bin "${helix}/bin/hx" (upstream: ''
        exec '${upstream}' \
          --config '${./pkgs/helix}/config.toml' \
          "$@"
      '')
    );

    my-git = { git }: (
      override-bin "${git}/bin/git" (upstream: ''
        export XDG_CONFIG_HOME='${xdg-config}'
        exec '${upstream}' "$@"
      '')
    );

    my-leftwm = { leftwm }: (
      override-bin "${leftwm}/bin/leftwm" (upstream: ''
        export XDG_CONFIG_HOME='${xdg-config}'
        exec '${upstream}' "$@"
      '')
    );

    # This is super ugly. How can we expose `mk-wrapper` from bash-scripts package?
    my-zellij-new-tab-wrapper = { writeShellScriptBin }: (
      writeShellScriptBin "zellij-new-tab" ''
        source '${./pkgs/bash-scripts}/prelude.bash'

        function main
        {
          parse-args 'layout=default *args' "$@"
          zellij action new-tab \
            --layout-dir '${./pkgs/zellij/confdir}/layouts' \
            --layout "$layout" \
            "''${args[@]}"
        }

        source '${./pkgs/bash-scripts}/postlude.bash'
      ''
    );

    my-startx = { my-bashrc-dir, my-leftwm, writeShellScriptBin }: (
      let
        # Hard-coded external dependency:
        systemStartx = "/run/current-system/sw/bin/startx";
      in
        writeShellScriptBin "homebase-startx" ''
          source "${my-bashrc-dir}/share/bashrc-dir/without-startx.sh"
          exec "${systemStartx}" "${my-leftwm}/bin/leftwm" "$@"
        '';
    );

    # FIXME BELOW:
    my-bash-scripts = {}: homebase.imp ./pkgs/bash-scripts;
    my-cargo-depgraph-svg = {}: homebase.imp ./pkgs/cargo-depgraph-svg;
    my-bashrc-dir = {}: homebase.imp ./pkgs/bashrc-dir;
  };
in
  all-new-pkgs.user-environment
