{ wrapBin, ... }: wrapBin {
  pkg = "herbstluftwm";
  wrapArgs = [ "--autostart" "${./autostart}" ];
}
