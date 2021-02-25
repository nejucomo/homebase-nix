{ wrapBin, ... }: wrapBin {
  pkg = "bashInteractive";
  binName = "bash";
  wrapArgs = [ "--rcfile" "${./bashrc}" ];
}

