# System-specific extra `nixpkgs` selections.
{
  perSystem =
    { lib, pkgs, system, ... }:
    lib.mkIf (system == "x86_64-linux") {
      packages = with pkgs; {
        inherit
          acpi
          adwaita-icon-theme
          coreutils
          dmenu
          i3lock
          killall
          libnotify
          openssh
          scrot
          signal-desktop
          xclip
          xss-lock
          ;
        xorg-xhost = xorg.xhost;
        xorg-xsetroot = xorg.xsetroot;
      };
    };
}
