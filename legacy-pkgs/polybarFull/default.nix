{ wrapBins, ... }: {}: wrapBins rec {
  polybar = { realbin, ... }: ''
    #!/bin/sh
    exec "${realbin}" "--config=${./config.ini}" "$@"
  '';
}

