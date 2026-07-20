# System-specific extra `nixpkgs` selections.
{
  perSystem =
    { pkgs, system, ... }:
    {
      packages =
        {
          x86_64-linux = with pkgs; {
            inherit
              acpi
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
            gnome3-adwaita-icon-theme = gnome3.adwaita-icon-theme;
            xorg-xhost = xorg.xhost;
            xorg-xsetroot = xorg.xsetroot;
          };

          aarch64-darwin = {
            inherit (pkgs) libiconv;
          };
        }
        .${system} or { };
    };
}
