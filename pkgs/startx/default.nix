/* Override startx to launch our homebase-managed window manager. */
let
  # Hard-coded dependency:
  systemStartx = "/run/current-system/sw/bin/startx";
in
  { pkgScript, ... }: { herbstluftwm }: pkgScript ''
    #!/bin/sh
    exec "${systemStartx}" "${herbstluftwm}/bin/herbstluftwm" "$@"
  ''
