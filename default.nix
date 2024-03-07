flake-inputs:
let
  # We have one hard-coded external dependency:
  systemStartx = "/run/current-system/sw/bin/startx";

  inherit (flake-inputs) nixpkgs;
  inherit (import ./lib-homebase nixpkgs)
    define-user-environment
    override-bin
  ;

  # Base packages are available for constructing the user environment,
  # but are not implicitly in the user environment:
  base-pkgs = nixpkgs // flake-inputs;

in define-user-environment base-pkgs {
  user-environment = pkgs@{
    # Customized packages:
    my-alacritty,
    my-bash,
    my-bash-scripts,
    my-cargo-depgraph-svg,
    my-dunst,
    my-git,
    my-git-clone-canonical,
    my-helix,
    my-leftwm,
    my-polybar,
    my-startx,
    my-tmux,
    my-vim,
    my-zellij,
    my-zellij-new-tab-wrapper,

    # Vanilla upstream packages:
    acpi,
    cargo-checkmate,
    cargo-udeps,
    coreutils,
    dmenu,
    file,
    findutils,
    firefox,
    gawk,
    gcc,
    gnugrep,
    gnused,
    gzip,
    i3lock,
    killall,
    less,
    libnotify,
    magic-wormhole,
    man,
    man-pages,
    man-pages-posix,
    meld,
    nix,
    nix-index,
    ps,
    pstree,
    ripgrep,
    rustup,
    scrot,
    signal-desktop,
    unclutter,
    which,
    xclip,
    xss-lock,
  }: (
    # The user environment is all of the above packages:
    pkgs
  );

  # Define packages which are either in the user environment or
  # dependencies thereof:
  
  # Pull some stuff out of deeper nested nixpkgs:
  xhost = { xorg }: xorg.xhost;
  xsetroot = { xorg }: xorg.xsetroot;
  adwaita-icon-theme = { gnome3 }: gnome3.adwaita-icon-theme;

  my-cargo-depgraph-svg = {
    writeShellScriptBin,
    cargo-depgraph,
    graphviz,
  }:
    let
      depgraph = "${cargo-depgraph}/bin/cargo-depgraph";
      dot = "${graphviz}/bin/dot";
    in
      writeShellScriptBin "cargo-depgraph-svg" ''
        if [ "$*" = '--help' ]
        then
          ${depgraph} --help
        else
          ${depgraph} "$@" \
            | sed 's/^digraph {$/\0\nrankdir="LR"/' \
            | ${dot} -Tsvg \
            > target/depgraph.svg
        fi
      '';

  my-bash-postlude = {}: "${./pkgs/bash-postlude}/postlude.bash";

  my-bash-scripts = deps@{
    lib,
    my-bash-postlude,
    writeShellScriptBin,
    symlinkJoin,
    stdenvNoCC
  }:
    import ./pkgs/bash-scripts deps;

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
    '')
  );

  my-bash = { bashInteractive }: (
    override-bin "${bashInteractive}/bin/bash" (upstream: ''
      exec '${upstream}' \
        --rcfile '${./pkgs/bashrc-dir}/bashrc' \
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
      export XDG_CONFIG_HOME='${./xdg-config}'
      exec '${upstream}' "$@"
    '')
  );

  my-leftwm = { leftwm }: (
    override-bin "${leftwm}/bin/leftwm" (upstream: ''
      export XDG_CONFIG_HOME='${./xdg-config}'
      exec '${upstream}' "$@"
    '')
  );

  my-zellij-new-tab-wrapper = { my-bash-postlude, my-zellij, writeShellScriptBin }: (
    writeShellScriptBin "zellij-new-tab" ''
      function main
      {
        parse-args 'layout=default *args' "$@"
        '${my-zellij}/bin/zellij' action new-tab \
          --layout-dir '${./pkgs/zellij/confdir}/layouts' \
          --layout "$layout" \
          "''${args[@]}"
      }

      source '${my-bash-postlude}'
    ''
  );

  my-startx = { my-leftwm, writeShellScriptBin }: (
    writeShellScriptBin "homebase-startx" ''
      source "${./pkgs/bashrc-dir}/without-startx.sh"
      exec "${systemStartx}" "${my-leftwm}/bin/leftwm" "$@"
    ''
  );
}
