DEV_PREFIX='/sys/class/backlight'

function main
{
  parse-args 'cmd=get *args' "$@"

  set-device-name
  case "$cmd" in
    device|get|set|brighter|dimmer)
      ;;
    *) fail "unknown command: $cmd"
  esac

  if eval "cmd-$cmd" "${args[@]}"
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

function cmd-device
{
  echo "$DEVICE"
}

function cmd-get
{
  cat "$DEV_PREFIX/$DEVICE/brightness"
}

function cmd-set
{
  parse-args 'value' "$@"
  echo "$value" | tee "$DEV_PREFIX/$DEVICE/brightness"
}

function cmd-brighter
{
  mutate-value '+ 1' '5 / 4'
}

function cmd-dimmer
{
  mutate-value '- 1' '4 / 5'
}

function mutate-value
{
  parse-args 'delta factor' "$@"
  local min=1
  local max="$(cat "$DEV_PREFIX/$DEVICE/max_brightness")"
  local v="$(cmd-get)"
  local v=$(( ( "$v" $delta ) * $factor ))
  if (( "$v" < "$min" ))
  then
    local v="$min"
  elif (( "$v" > "$max" ))
  then
    local v="$max"
  fi
  cmd-set "$v"
}
