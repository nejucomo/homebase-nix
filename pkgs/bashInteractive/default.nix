{ wrapBinArgs, ... }: wrapBinArgs {
  binName = "bash";
  wrapArgs = [ "--rcfile" "${./bashrc}" ];
}

