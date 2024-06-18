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
    my-journal-viewer,
    my-leftwm,
    my-polybar,
    my-signal-desktop,
    my-startx,
    my-tmux,
    my-vim,
    my-zellij,

    # Vanilla upstream packages:
    acpi,
    cargo-autoinherit,
    cargo-checkmate,
    cargo-expand,
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
    jq,
    killall,
    less,
    libnotify,
    logseq,
    magic-wormhole,
    man,
    man-pages,
    man-pages-posix,
    meld,
    # niri,
    nix-index,
    openssh,
    ps,
    pstree,
    #radicle,
    ripgrep,
    rustup,
    sccache,
    scrot,
    signal-desktop,
    tokei,
    toml2json,
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
          ${depgraph} depgraph --help
        else
          ${depgraph} depgraph "$@" \
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
      export XDG_CONFIG_HOME='${./xdg-config}'
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
      exec '${upstream}' "$@"
    '')
  );

  my-leftwm = { symlinkJoin, leftwm }: (
    let
      name = "leftwm-wrapper-scripts";
      wrapped = (
        let
          to-wrap = [
            "leftwm"
            "leftwm-worker"
          ];
          wrap = bin-name: override-bin "${leftwm}/bin/${bin-name}" (upstream: ''
            exec '${upstream}' "$@"
          '');
        in
          map wrap to-wrap
      );
      leftwm-log = override-bin "${leftwm}/bin/leftwm-log" (upstream: ''
        export PATH="${leftwm}/bin:$PATH"
        exec '${upstream}' "$@"
      '');
    in
      symlinkJoin {
        inherit name;
        paths = wrapped ++ [leftwm-log leftwm];
      }
  );

  my-journal-viewer = { my-alacritty, my-zellij, writeShellScriptBin }: (
    writeShellScriptBin "journal-viewer" ''
      exec '${my-alacritty}/bin/alacritty' --command '${my-zellij}/bin/zellij' --session 'journal-viewer' --layout '${./pkgs/zellij/homebase-layouts}/logs.kdl'
    ''
  );

  my-signal-desktop = { signal-desktop }: (
    override-bin "${signal-desktop}/bin/signal-desktop" (up: ''
      export XDG_CONFIG_HOME="$HOME/.config"
      exec '${up}' "$@"
    '')
  );

  my-startx = { my-leftwm, openssh, writeShellScriptBin }: (
    writeShellScriptBin "homebase-startx" ''
      source '${./pkgs/bashrc-dir}/without-startx.sh'
      exec '${systemStartx}' '${openssh}/bin/ssh-agent' '${my-leftwm}/bin/leftwm' "$@"
    ''
  );
}
