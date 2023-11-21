{ wrapBins, ... }: wrapBins rec {
  dunst = { realbin, ... }: ''
    #!/bin/sh
    exec "${realbin}" -conf "${./dunst.conf}" "$@"
  '';
}

