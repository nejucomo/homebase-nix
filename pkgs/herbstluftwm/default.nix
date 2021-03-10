{ wrapBinArgs, ... }: wrapBinArgs {
  pkg = "herbstluftwm";
  wrapArgs = [ "--autostart" "${./autostart}" ];
}
