{ wrapBinArgs, ... }: wrapBinArgs {
  wrapArgs = [ "--autostart" "${./autostart}" ];
}
