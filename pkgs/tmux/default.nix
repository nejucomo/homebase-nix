{ wrapBins, ... }: wrapBins {
  tmux = { realbin, ... }: ''
    #!/bin/sh
    exec "${realbin}" -f "${./tmux.conf}" "$@"
  '';
}
