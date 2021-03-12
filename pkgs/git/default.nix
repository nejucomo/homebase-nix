{ wrapBins, ... }: wrapBins {
  git = { realbin, ... }: ''
    #!/bin/sh
    export XDG_CONFIG_HOME="${./xdgconf}"
    exec "${realbin}" "$@"
  '';
}
