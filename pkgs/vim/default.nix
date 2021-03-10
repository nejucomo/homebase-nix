{ wrapBinArgs, ... }: wrapBinArgs {
  pkg = "vim";
  wrapArgs = [ "-u" "${./vimrc}" ];
}
