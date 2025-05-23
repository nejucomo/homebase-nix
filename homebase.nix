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
    inherit (lib.forSystem system)
      imp
      basePkgs
      templatePackage
    ;

    commonPkgs = basePkgs.flakes // rec {
      inherit (basePkgs.nix)
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

      inherit (basePkgs.nix.llvmPackages)
        bintools
      ;

      # Packages defined in this repo:
      bashrc-dir = templatePackage ./pkg/bashrc-dir {};

      xdg-config = templatePackage ./pkg/xdg-config {};

      bash = templatePackage ./pkg/bash {
        inherit
          bashrc-dir
          xdg-config
        ;

        inherit (basePkgs.nix)
          bashInteractive
        ;
      };

      bash-postlude = templatePackage ./pkg/bash-postlude {};

      # TODO: re-implement self-testing during build:
      bash-scripts = templatePackage ./pkg/bash-scripts {
        inherit bash-postlude;
      };

      cargo-depgraph-svg = templatePackage ./pkg/cargo-depgraph-svg {
        inherit (basePkgs.nix)
          cargo-depgraph
          graphviz
        ;
      };

      set-symlink = templatePackage ./pkg/set-symlink {
        inherit bash-postlude;
      };

      git-clone-canonical = templatePackage ./pkg/git-clone-canonical {
        inherit bash-postlude set-symlink;
        inherit (basePkgs.flakes) git-clone-canonical;
      };

      # Not yet working:
      # git-user-hooks = templatePackage ./pkg/git-user-hooks {
      #   inherit bash-postlude set-symlink;
      #   inherit (basePkgs.flakes) git-clone-canonical;
      # };
    };

    sysPkgs = {
      "x86_64-linux" = {
        inherit (basePkgs.nix)
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

        inherit (basePkgs.nix.xorg)
          xhost
          xsetroot
        ;

        inherit (basePkgs.nix.gnome3)
          adwaita-icon-theme
        ;
      };

      "aarch64-darwin" = {
        inherit (basePkgs.nix)
          # Needed for some rust crates to build on macos:
          libiconv
        ;
      };
    };

  in commonPkgs // sysPkgs."${system}"
)

  # in define-user-environment base-pkgs {
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
