DEV_PREFIX='/sys/class/backlight'

function main
{
  [ $# -gt 0 ] || fail 'usage: {get-name|get-value|set-value VALUE}'
  local cmd="$1"; shift;

  case "$cmd" in
    get-name|get-value)
      [ -$# -eq 0 ] || fail "Unexpected arguments: $*"
      set-device-name
      ;;
    set-value)
      set-device-name
      ;;
    *) fail "unknown command: $cmd"
  esac

  if eval "$cmd" "$@"
  then
    return 0
  else
    return $?
  fi
}

function set-device-name
{
  DEVICE="$(ls "$DEV_PREFIX")"

  if [ "$(echo "$DEVICE)" | wc -l)" -ne 1 ]
  then
    fail "Failed to find a single device. Found: $DEVICE"
  fi
}

function get-name
{
  echo "$DEVICE"
}

function get-value
{
  cat "$DEV_PREFIX/$DEVICE/brightness"
}

function set-value
{
  parse-args 'value' "$@"
  echo "$value" > "$DEV_PREFIX/$DEVICE/brightness"
}
