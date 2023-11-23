let
  nixpkgs = import <nixpkgs> {};

  basepkgs = with nixpkgs; [
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
    nix
    libnotify
    ps
    pstree
    ripgrep
    unclutter
    which
    xorg.xsetroot
    xss-lock
  ];

  cookedpkgs =
    let
      flatten = nixpkgs.lib.lists.flatten;
      cook = pkg:
        if pkg ? man
        then [pkg pkg.man]
        else [pkg];
    in
      flatten (map cook basepkgs);

  manonly = map (pkg: pkg.man) (with nixpkgs; [
    dunst
    herbstluftwm
  ]);
in
  cookedpkgs ++ manonly
