# Design principles:
#
# - As few lines of code here should be anything besides selecting packages.
# - Package imports should minimize lines of code.
# - So everything else lives in `./lib`.
supportedSystems: flakeInputs:

let
  lib = import ./lib flakeInputs { unfreePackages = [ "claude-code" ]; };
in
lib.defineHomebase supportedSystems (
  system:
  let
    inherit (lib.forSystem system) imp basePkgs templatePackage;

    # Packages defined in this repo:
    hbdeps = {
      bash-postlude = templatePackage ./pkg/bash-postlude "lib" { };

      git-current-branch = templatePackage ./pkg/git-current-branch "bin" {
        inherit (hbdeps) bash-postlude;
        inherit (basePkgs.nix) git sd;
      };

      git-summarize-dirt = templatePackage ./pkg/git-summarize-dirt "bin" {
        inherit (hbdeps) bash-postlude git-current-branch;
        inherit (basePkgs.nix) git sd;
      };

      bashrc-dir = templatePackage ./pkg/bashrc-dir "etc/bashrc-dir" {
        inherit (basePkgs.nix) sd;
        inherit (hbdeps) git-summarize-dirt;
      };

      git-user-hooks = templatePackage ./pkg/git-user-hooks "lib/git-user-hooks" {
        inherit (hbdeps) bash-postlude set-symlink;
        inherit (basePkgs.flakes) git-clone-canonical;
      };

      nixfmt = templatePackage ./pkg/nixfmt "bin" {
        inherit (basePkgs.nix) nixfmt-rfc-style;
        inherit (hbdeps) bash-postlude;
      };

      xdg-config = templatePackage ./pkg/xdg-config "etc/xdg" {
        inherit (hbdeps) git-user-hooks bashrc-dir nixfmt;
      };

      set-symlink = templatePackage ./pkg/set-symlink "bin" { inherit (hbdeps) bash-postlude; };
    };

    # Here we collate all packages directly available in the userspace:
  in
  lib.lists.flatten [
    # All custom homebase dependencies:
    (builtins.attrValues hbdeps)

    # Next is our top-level custom (non-dependency) packages:
    [
      (templatePackage ./pkg/nix "bin" {
        inherit (hbdeps) bash-postlude;
        inherit (basePkgs.nix) nix;
      })

      (templatePackage ./pkg/bash "bin" {
        inherit (hbdeps) bashrc-dir xdg-config;
        inherit (basePkgs.nix) bashInteractive;
      })

      # TODO: re-implement self-testing during build:
      (templatePackage ./pkg/bash-scripts "bin" { inherit (hbdeps) bash-postlude; })
      (templatePackage ./pkg/cargo-depgraph-svg "bin" { inherit (basePkgs.nix) cargo-depgraph graphviz; })
      (templatePackage ./pkg/wormhole "bin" { inherit (basePkgs.nix) magic-wormhole; })
      (templatePackage ./pkg/git-clone-canonical "bin" {
        inherit (hbdeps) bash-postlude set-symlink;
        inherit (basePkgs.flakes) git-clone-canonical;
      })
      (templatePackage ./pkg/git-log-fork "bin" {
        inherit (hbdeps) bash-postlude;
        inherit (basePkgs.nix) bash git;
      })
      (templatePackage ./pkg/zellij "bin" {
        inherit (hbdeps) xdg-config;
        inherit (basePkgs.nix) zellij;
      })
    ]

    # flake packages:
    (builtins.attrValues basePkgs.flakes)

    # the subset of nixpkgs we want:
    (with basePkgs.nix; [
      # logseq
      # niri
      # penumbra
      # radicle
      # sccache
      #cargo-checkmate
      #firefox
      #man-pages
      #man-pages-posix
      cargo-autoinherit
      cargo-expand
      cargo-udeps
      clang
      claude-code
      fd
      file
      findutils
      gawk
      git
      gnugrep
      gnused
      gzip
      helix
      jq
      less
      llvmPackages.bintools
      man
      meld
      nix-index
      ps
      pstree
      ripgrep
      rustup
      sapling
      sd
      tokei
      toml2json
      which
    ])

    # Define package-specific packages:
    (
      with basePkgs.nix;
      {
        "x86_64-linux" = [
          # unclutter
          acpi
          coreutils
          dmenu
          gnome3.adwaita-icon-theme
          i3lock
          killall
          libnotify
          openssh
          scrot
          signal-desktop
          xclip
          xorg.xhost
          xorg.xsetroot
          xss-lock
        ];

        "aarch64-darwin" = [
          # Needed for some rust crates to build on macos:
          libiconv
        ];
      }

      # Select the system-specifc packages:
      ."${system}"
    )
  ]
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
