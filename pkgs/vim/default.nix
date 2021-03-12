{ wrapBinArgs, ... }: wrapBinArgs {
  wrapArgs = [ "-u" "${./vimrc}" ];
}
