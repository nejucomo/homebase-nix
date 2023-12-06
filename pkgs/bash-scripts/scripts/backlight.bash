DEV_PREFIX='/sys/class/backlight'

function main
{
  parse-args 'cmd=get *' "$@"

  case "$cmd" in
    device|get|brighter|dimmer)
      parse-args '' "$@"
      set-device-name
      ;;
    set)
      set-device-name "$value"
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

function device
{
  echo "$DEVICE"
}

function get
{
  cat "$DEV_PREFIX/$DEVICE/brightness"
}

function set
{
  parse-args 'value' "$@"
  echo "$value" | tee "$DEV_PREFIX/$DEVICE/brightness"
}

function brighter
{
  mutate-value '5 / 4'
}

function dimmer
{
  mutate-value '4 / 5'
}

function mutate-value
{
  local factor="$1"
  local min=1
  local max="$(cat "$DEV_PREFIX/$DEVICE/max_brightness")"
  local v="$(get)"
  local v=$(( "$v" * $factor ))
  if (( "$v" < "$min" ))
  then
    local v="$min"
  elif (( "$v" > "$max" ))
  then
    local v="$max"
  fi
  set "$v"
}
