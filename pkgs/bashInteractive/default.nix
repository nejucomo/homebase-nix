{ wrapBins, ... }: wrapBins rec {

  bash = { realbin, ... }: ''
    #!/bin/sh
    exec "${realbin}" "--rcfile" "${./bashlib}/bashrc" "$@"
  '';

  sh = bash;
}
