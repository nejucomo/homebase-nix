# Design principles:
#
# - As few lines of code here should be anything besides selecting packages.
# - Package imports should minimize lines of code.
# - So everything else lives in `./lib`.
supportedSystems:
flakeInputs:

let lib = import ./lib flakeInputs;
in lib.defineHomebase supportedSystems (system:
  let
    base = lib.basePackagesForSystem system;
  
    commonPkgs = base.flakes // {
      inherit (base.nix)
        cargo-autoinherit
        #cargo-checkmate
        cargo-expand
        cargo-udeps
        clang
        coreutils
        file
        findutils
        #firefox
        gawk
        gcc
        git
        gnugrep
        gnused
        gzip
        helix
        jq
        less
        # logseq
        magic-wormhole # TODO: adjust install paths
        man
        #man-pages
        #man-pages-posix
        meld
        # niri
        nix-index
        openssh
        # penumbra
        ps
        pstree
        # radicle
        ripgrep
        rustup
        # sccache
        tokei
        toml2json
        which
      ;

      inherit (base.nix.llvmPackages)
        bintools
      ;
    };

    sysPkgs = {
      "x86_64-linux" = {
        inherit (base.nix)
          acpi
          dmenu
          i3lock
          killall
          libnotify
          scrot
          signal-desktop
          # unclutter
          xclip
          xss-lock
        ;

        inherit (base.nix.xorg)
          xhost
          xsetroot
        ;

        inherit (base.nix.gnome3)
          adwaita-icon-theme
        ;
      };

      "aarch64-darwin" = {
        inherit (base.nix)
          # Needed for some rust crates to build on macos:
          libiconv
        ;
      };
    };

  in commonPkgs // sysPkgs."${system}"
)

  # in define-user-environment base-pkgs {
  #   my-cargo-depgraph-svg = {
  #     writeShellScriptBin,
  #     cargo-depgraph,
  #     graphviz,
  #   }:
  #     let
  #       depgraph = "${cargo-depgraph}/bin/cargo-depgraph";
  #       dot = "${graphviz}/bin/dot";
  #     in
  #       writeShellScriptBin "cargo-depgraph-svg" ''
  #         if [ "$*" = '--help' ]
  #         then
  #           ${depgraph} depgraph --help
  #         else
  #           ${depgraph} depgraph "$@" \
  #             | ${dot} -Tsvg \
  #             > target/depgraph.svg
  #         fi
  #       '';
  #
  #   my-bash-scripts = deps@{ stdenvNoCC }: (
  #     let
  #       fulldeps = deps // { inherit package-bash-scripts; };
  #     in
  #       import ./pkgs/bash-scripts fulldeps
  #   );
  #
  #   my-git-clone-canonical = { git-clone-canonical }: (
  #     override-bin "${git-clone-canonical}/bin/git-clone-canonical" (up: ''
  #       if [ "$#" -eq 1 ] && ! [[ "$1" =~ ^- ]]
  #       then
  #         # update links after execution:
  #         '${up}' "$@" && update-hack-links
  #       elif [ "$#" -eq 2 ] && [ "$1" = '--show-path' ]
  #       then
  #         # Modify path:
  #         echo "$HOME/hack/$(basename "$('${up}' "$@")")"
  #       else
  #         # passthru:
  #         exec '${up}' "$@"
  #       fi
  #     '')
  #   );
  #
  #   my-gituserhooks = { runCommand }: (
  #     let gituserhooks = package-bash-scripts ./pkgs/gituserhooks;
  #     in runCommand "my-wrapper" { inherit gituserhooks; } ''
  #       set -x
  #       mkdir -p $out/share
  #       ln -s ${gituserhooks} $out/share/gituserhooks
  #       set +x
  #     ''
  #   );
  #
  #   my-bash = { bashInteractive }: (
  #     override-bin "${bashInteractive}/bin/bash" (upstream: ''
  #       export XDG_CONFIG_HOME='${./xdg-config}'
  #       exec '${upstream}' \
  #         --rcfile '${./pkgs/bashrc-dir}/bashrc' \
  #         "$@"
  #     '')
  #   );
  #
  #   my-alacritty = { alacritty }: (
  #     override-bin "${alacritty}/bin/alacritty" (upstream: ''
  #       exec '${upstream}' \
  #         --config-file '${./pkgs/alacritty/alacritty.toml}' \
  #         "$@"
  #     '')
  #   );
  #
  #   my-dunst = { dunst }: (
  #     override-bin "${dunst}/bin/dunst" (upstream: ''
  #       exec '${upstream}' \
  #         --config-file '${./pkgs/dunst/dunst.conf}' \
  #         "$@"
  #     '')
  #   );
  #
  #   my-polybar = { polybar }: (
  #     override-bin "${polybar}/bin/polybar" (upstream: ''
  #       exec '${upstream}' \
  #         --config='${./pkgs/polybar/config.ini}' \
  #         "$@"
  #     '')
  #   );
  #
  #   my-tmux = { tmux }: (
  #     override-bin "${tmux}/bin/tmux" (upstream: ''
  #       exec '${upstream}' \
  #         -f '${./pkgs/tmux/tmux.conf}' \
  #         "$@"
  #     '')
  #   );
  #
  #   my-vim = { vim }: (
  #     override-bin "${vim}/bin/vim" (upstream: ''
  #       exec '${upstream}' \
  #         -u '${./pkgs/vim/vimrc}' \
  #         "$@"
  #     '')
  #   );
  #
  #   my-zellij = { zellij }: (
  #     override-bin "${zellij}/bin/zellij" (upstream: ''
  #       exec '${upstream}' \
  #         --config-dir '${./pkgs/zellij}/confdir' \
  #         "$@"
  #     '')
  #   );
  #
  #   my-leftwm = { symlinkJoin, leftwm }: (
  #     let
  #       name = "leftwm-wrapper-scripts";
  #       wrapped = (
  #         let
  #           to-wrap = [
  #             "leftwm"
  #             "leftwm-worker"
  #           ];
  #           wrap = bin-name: override-bin "${leftwm}/bin/${bin-name}" (upstream: ''
  #             exec '${upstream}' "$@"
  #           '');
  #         in
  #           map wrap to-wrap
  #       );
  #       leftwm-log = override-bin "${leftwm}/bin/leftwm-log" (upstream: ''
  #         export PATH="${leftwm}/bin:$PATH"
  #         exec '${upstream}' "$@"
  #       '');
  #     in
  #       symlinkJoin {
  #         inherit name;
  #         paths = wrapped ++ [leftwm-log leftwm];
  #       }
  #   );
  #
  #   my-journal-viewer = { my-alacritty, my-zellij, writeShellScriptBin }: (
  #     writeShellScriptBin "journal-viewer" ''
  #       exec '${my-alacritty}/bin/alacritty' --command '${my-zellij}/bin/zellij' --session 'journal-viewer' --layout '${./pkgs/zellij/homebase-layouts}/logs.kdl'
  #     ''
  #   );
  #
  #   #my-signal-desktop = { signal-desktop }: (
  #   #  override-bin "${signal-desktop}/bin/signal-desktop" (up: ''
  #   #    export XDG_CONFIG_HOME="$HOME/.config"
  #   #    exec '${up}' "$@"
  #   #  '')
  #   #);
  #
  #   my-startx = { my-leftwm, openssh, writeShellScriptBin }: (
  #     writeShellScriptBin "homebase-startx" ''
  #       source '${./pkgs/bashrc-dir}/without-startx.sh'
  #       exec '${systemStartx}' '${openssh}/bin/ssh-agent' '${my-leftwm}/bin/leftwm' "$@"
  #     ''
  #   );
  # }


