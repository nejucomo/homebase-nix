{ wrapBins, ... }: wrapBins rec {

  bash = { realbin, ... }: ''
    #!/bin/sh
    exec "${realbin}" "--rcfile" "${./bashrc}" "$@"
  '';

  sh = bash;
}
