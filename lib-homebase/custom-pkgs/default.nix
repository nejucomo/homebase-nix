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
    git = import-legacy-pkg "git" {};

    herbstluftwm = import-legacy-pkg "herbstluftwm" {
      inherit (pkgs)
        alacritty
        bash
        dunst
        firefox
        i3lock
        polybar
        tmux
        unclutter
        xsetroot
        xss-lock
      ;
    };

    startx = import-legacy-pkg "startx" {
      inherit herbstluftwm;
    };
  }
