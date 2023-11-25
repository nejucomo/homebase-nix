/*
  TO BE DEPRECATED

  A function mapping a packages dir to a list of derivations defining
  the user environment.

  Pseudo type signature: `pkgsDir -> [ derivation ]`

  The `pkgsDir` must be a directory with zero or more "custom package
  directories".

  Each custom package directory must have a `default.nix` (so the
  directory can be imported) which provides a function matching the
  `./import-pkg.nix` interface.
*/

homebase: legacy-pkgs-dir: pkgs:
let
  inherit (builtins) attrNames readDir;

  import-legacy-pkg = homebase.imp ./import-pkg.nix legacy-pkgs-dir;
in
  rec {
    vim = import-legacy-pkg "vim" {};
    tmux = import-legacy-pkg "tmux" {};
    polybar = import-legacy-pkg "polybarFull" {};
    journalctl-sidebar = import-legacy-pkg "journalctl-sidebar" {};
    git = import-legacy-pkg "git" {};
    dunst = import-legacy-pkg "dunst" {};
    alacritty = import-legacy-pkg "alacritty" {};

    herbstluftwm = import-legacy-pkg "herbstluftwm" {
      inherit (pkgs)
        bash
        firefox
        i3lock
        unclutter
        xsetroot
        xss-lock
      ;
      inherit
        alacritty
        dunst
        polybar
        tmux
      ;
    };

    startx = import-legacy-pkg "startx" {
      inherit herbstluftwm;
    };
  }
