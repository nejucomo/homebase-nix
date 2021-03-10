{ nixpkgs, wrapBinCb, ... }: wrapBinCb {
  pkg = "git";
  mkBinBody = { realbin, ... }: ''
    #!/bin/sh
    export XDG_CONFIG_HOME="${./xdgconf}"
    exec "${realbin}" "$@"
  '';
}
