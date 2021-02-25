# Override startx with a hard-coded mutable path for system startx:
{ pkgName, writeScriptBin, importPkg, ... }:
  let
    hlwm = importPkg "herbstluftwm";
  in
    writeScriptBin pkgName ''
      #!/bin/sh
      exec /run/current-system/sw/bin/startx ${hlwm}/bin/herbstluftwm "$@"
    ''
