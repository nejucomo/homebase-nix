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

          aarch64-darwin = {
            inherit (pkgs) libiconv;
          };
        }
        .${system} or { };
    };
}
