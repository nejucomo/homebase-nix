## Wrap bash so that it loads our baked-in rcfile
{ nixpkgs, wrap-bins, ... }: wrap-bins nixpkgs.bashInteractive {
  bash = { upstream-bin, ... }: ''
    #! ${upstream-bin}
    exec "${upstream-bin}" "--rcfile" "${./bashlib}/bashrc" "$@"
  '';
}
