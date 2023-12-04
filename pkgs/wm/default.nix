{ nixpkgs, sub-pname, wrap-configs, ... }:
dependency-pkgs@{
  alacritty,
  bash,
  bash-scripts,
  dunst,
  firefox,
  i3lock,
  polybar,
  tmux,
  unclutter,
  xsetroot,
  xss-lock
}:
let
  dependencies =
    let
      inherit (nixpkgs.lib.attrsets) mapAttrs;

      get-bin = name: pkg: "${pkg}/bin/${name}";

      synonymous-bins = mapAttrs get-bin (removeAttrs dependency-pkgs [ "bash-scripts" ]);
    in
      synonymous-bins // {
        touchpad = "${bash-scripts}/bin/touchpad";
      };

  autostart = nixpkgs.writeScript (sub-pname "wm-autostart") ''
    #! ${dependencies.bash}

    set -efuxo pipefail

    exec > ~/.herbstluftwm.log
    exec 2>&1

    # If anything fails in autostart, quit hlwm:
    trap 'ECODE=$?; [ "$ECODE" == 0 ] || herbstclient quit; exit $ECODE' EXIT

    echo $PATH | tr ':' '\n'

    function hc
    {
        herbstclient "$@"
    }

    function keybind
    {
      local kb="$1"
      shift
      local old="$(hc list_keybinds | tr '\t' ' ' | tr '+' '-' | grep "$kb ")"
      if [ -z "$old" ]
      then
        hc keybind "$kb" "$@"
      else
        exit 1
      fi
    }

    Mod=Mod4   # Use the super key as the main modifier

    hc keyunbind --all

    # Top-level WM control
    keybind $Mod-Shift-q quit
    keybind $Mod-Shift-r reload
    keybind $Mod-Shift-c close
    keybind $Mod-Shift-z spawn '${dependencies.i3lock}' -c "''${HOMEBASE_USER_COLOR:-554466}"

    # Input mode controls
    keybind $Mod-Escape spawn '${dependencies.touchpad}' 'toggle-enabled'

    # App shortcuts
    keybind $Mod-Return spawn '${dependencies.alacritty}'
    keybind $Mod-Shift-Return spawn '${dependencies.alacritty}' --command '${dependencies.tmux}' new-session -A -s default &
    keybind $Mod-b spawn '${dependencies.firefox}' --private-window
    keybind $Mod-Shift-b spawn '${dependencies.firefox}' -P authenticated

    keybind $Mod-h     focus left
    keybind $Mod-j     focus down
    keybind $Mod-k     focus up
    keybind $Mod-l     focus right

    keybind $Mod-Shift-h     shift left
    keybind $Mod-Shift-j     shift down
    keybind $Mod-Shift-k     shift up
    keybind $Mod-Shift-l     shift right

    # tags
    TAG_NAMES=( {1..9} )
    TAG_KEYS=( {1..9} 0 )

    hc rename default "''${TAG_NAMES[0]}" || true
    for i in ''${!TAG_NAMES[@]} ; do
        hc add "''${TAG_NAMES[$i]}"
        key="''${TAG_KEYS[$i]}"
        if ! [ -z "$key" ] ; then
            keybind "$Mod-$key" use_index "$i"
            keybind "$Mod-Shift-$key" move_index "$i"
        fi
    done

    # cycle through tags
    keybind $Mod-period use_index +1 --skip-visible
    keybind $Mod-comma  use_index -1 --skip-visible

    # layouting
    keybind $Mod-Shift-s floating toggle
    keybind $Mod-Shift-f fullscreen toggle
    keybind $Mod-Shift-m set_layout max
    keybind $Mod-p pseudotile toggle
    keybind $Mod-space cycle_layout +1

    # split frames
    keybind $Mod-u       split   bottom  0.5
    keybind $Mod-o       split   right   0.5
    keybind $Mod-r       remove
    keybind $Mod-Control-space split explode

    # resizing frames and floating clients
    resizestep=0.02
    keybind $Mod-Control-h       resize left +$resizestep
    keybind $Mod-Control-j       resize down +$resizestep
    keybind $Mod-Control-k       resize up +$resizestep
    keybind $Mod-Control-l       resize right +$resizestep

    # mouse
    hc mouseunbind --all
    hc mousebind $Mod-Button1 move
    hc mousebind $Mod-Button2 zoom
    hc mousebind $Mod-Button3 resize

    # theme
    hc attr theme.active.outer_color '#ff00aa'
    hc attr theme.border_width 2
    hc attr theme.outer_width 2
    hc set frame_border_active_color '#aa00aa'
    hc set frame_border_normal_color 'black'
    hc set frame_border_width 1
    hc set frame_gap 0
    hc set window_gap 0

    # rules
    hc unrule -F
    hc rule focus=off
    hc rule class='alacritty' focus=on
    hc rule windowtype~'_NET_WM_WINDOW_TYPE_(DIALOG|UTILITY|SPLASH)' floating=on
    hc rule windowtype='_NET_WM_WINDOW_TYPE_DIALOG' focus=on
    hc rule windowtype~'_NET_WM_WINDOW_TYPE_(NOTIFICATION|DOCK|DESKTOP)' manage=off
    hc rule class='panel_bottom' index='11'

    hc unlock
    hc emit_hook reload

    if hc silent new_attr bool my_not_first_autostart
    then
      '${dependencies.xss-lock}' --transfer-sleep-lock \
        -- \
        '${dependencies.i3lock}' --nofork -c "''${HOMEBASE_USER_COLOR:-554466}" &

      '${dependencies.unclutter}' -idle 1 &
      '${dependencies.xsetroot}' -solid '#555588'
      '${dependencies.polybar}' &
      '${dependencies.dunst}' &
      '${dependencies.alacritty}' --command '${dependencies.tmux}' new-session -A -s default &
    fi
  '';
in
  wrap-configs nixpkgs.herbstluftwm {
    herbstluftwm = ''--autostart "${autostart}" '';
  }
