{ wrapBins, ... }: wrapBins {
  bash = { realbin, ... }: ''
    #!/bin/sh
    exec "${realbin}" "--rcfile" "${./bashrc}" "$@"
  '';
}
