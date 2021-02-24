{ wrapBin, ... }: wrapBin {
  pkg = "vim";
  wrapArgs = [ "-u" "${./vimrc}" ];
}
