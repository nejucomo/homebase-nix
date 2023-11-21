# TODO

- ☐ Add notification system
- ☐ herbstluftwm feature to add/jump-to/move-to tags by name
- ☐ screen lock all desktops with hot-key
- ☐ screen lock all desktops with lid close
- ☐ hlwm keybindings to control audio
- ☐ git info and other git goodies
- ☐ mouse pad sensitivity
- ☑ link all users to the same nix-profile
- ☑ screen dimming:
  - sorta working:
    - `programs.light.enable = true` enabled in `configuration.nix`.
    - users in `video` group.
    - The two above set `/sys/class/backlight` udev correctly; so users can peek/poke `/sys`.
    - `light` program doesn't emit any output as non-sudo.
    - It works as sudo.
