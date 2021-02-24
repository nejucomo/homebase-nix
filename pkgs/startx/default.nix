# Override startx with a hard-coded mutable path for system startx:
pkglib @ { nixpkgs, ... }:
  let
    hlwm = import ../herbstluftwm pkglib;
  in
    nixpkgs.writeScriptBin "startx" ''
      #!/bin/sh
      exec /run/current-system/sw/bin/startx ${hlwm}/bin/herbstluftwm "$@"
    ''
