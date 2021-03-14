/* Override startx to launch our homebase-managed window manager. */
let
  # Hard-coded dependency:
  systemStartx = "/run/current-system/sw/bin/startx";
in
  { pkgScript, importPkg, ... }:
    let
      # peer dependency:
      hlwm = importPkg "herbstluftwm";
    in
      pkgScript ''
        #!/bin/sh
        exec "${systemStartx}" "${hlwm}/bin/herbstluftwm" "$@"
      ''
