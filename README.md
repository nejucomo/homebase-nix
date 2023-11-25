# TODO

- ☐ simplify/refactor nix framework
  - enable cross-package dependencies for any package type
  - override base packages in a cleaner manner
  - convert to kebab-case everywhere instead of camelCase.
- ☐ herbstluftwm feature to add/jump-to/move-to tags by name
- ☐ hlwm keybindings to control audio
- ☐ hlwm keybindings to control brightness
- ☐ screen lock all desktops with hot-key
- ☑ git info and other git goodies
  - partial:
    - Couldn't incorporate userignore and user hooks.
- ☑ mouse pad sensitivity
- ☑ screen lock all desktops with lid close
- ☑ Add notification system
- ☑ enable user namespace sandboxing without setuid-root for nix-env-scoped brave
  - this is enabled, but neither brave nor google-chrome work.
- ☑ update to nixpkgs-unstable in user environment
- ☑ link all users to the same nix-profile
- ☑ screen dimming:
  - sorta working:
    - `programs.light.enable = true` enabled in `configuration.nix`.
    - users in `video` group.
    - The two above set `/sys/class/backlight` udev correctly; so users can peek/poke `/sys`.
    - `light` program doesn't emit any output as non-sudo.
    - It works as sudo.
