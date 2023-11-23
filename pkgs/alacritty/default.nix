{ wrapBins, ... }: wrapBins rec {
  alacritty = { realbin, ... }: ''
    #!/bin/sh
    exec "${realbin}" "--config-file" "${./alacritty.yml}" "$@"
  '';
}
