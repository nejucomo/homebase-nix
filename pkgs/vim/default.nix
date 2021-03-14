{ wrapBins, ... }: wrapBins {
  vim = { realbin, ... }: ''
    #!/bin/sh
    exec "${realbin}" -u "${./vimrc}" "$@"
  '';
}
