{ wrapBins, ... }: wrapBins rec {
  kitty = { realbin, ... }: ''
    #!/bin/sh
    exec "${realbin}" "--config" "${./kitty.conf}" "$@"
  '';
}
