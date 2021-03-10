{ wrapBinArgs, ... }: wrapBinArgs {
  pkg = "bashInteractive";
  binName = "bash";
  wrapArgs = [ "--rcfile" "${./bashrc}" ];
}

