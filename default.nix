imparams@{ nixpkgs }:
let
  pname = baseNameOf ./.;
  version = "0.1";

  homebase = import ./lib imparams;

  upstream-with-extras-pkgs = homebase.include-extras (
    with homebase.nixpkgs; [
      acpi
      coreutils
      findutils
      firefox
      gawk
      gnugrep
      gnused
      gzip
      helix
      i3lock
      killall
      less
      man
      meld
      nix
      libnotify
      ps
      pstree
      ripgrep
      unclutter
      which
      xorg.xsetroot
      xss-lock
    ]
  );

  # TODO: these are the man-pages of custom packages; update the custom packages to include the manpages themselves:
  man-only-pkgs = map (pkg: pkg.man) (with nixpkgs; [
    dunst
    herbstluftwm
  ]);

  custom-pkgs = homebase.custom-pkgs ./pkgs;
in
  nixpkgs.symlinkJoin {
    name = "${pname}-${version}";
    paths = upstream-with-extras-pkgs ++ man-only-pkgs ++ custom-pkgs;
  }
