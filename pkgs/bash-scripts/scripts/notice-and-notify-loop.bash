INTERVAL="${INTERVAL:-7}"

POWER_SUPPLY_THRESHOLD="${POWER_SUPPLY_THRESHOLD:-20}"

POWER_SUPPLY_BASE='/sys/class/power_supply'

RGX_DISCHARGING='^POWER_SUPPLY_STATUS=Discharging$'


function main
{
  parse-args '' "$@"

  set +f

  while sleep "$INTERVAL"
  do
    notice-and-notify
  done
}

function notice-and-notify
{
  for supply in $(power-supplies-discharging)
  do
    capacity="$(cat "$supply" | grep '^POWER_SUPPLY_CAPACITY=' | sed 's/^.*=//')"
    supply_name="$(echo "$supply" | sed "s|^$POWER_SUPPLY_BASE/||; s|/uevent||")"

    if [ "$capacity" -le "$POWER_SUPPLY_THRESHOLD" ]
    then
      notify-send \
        --urgency='critical' \
        --expire-time="$INTERVAL" \
        "${supply_name} low capacity"        
    fi
  done
}

function power-supplies-discharging
{
  rg --files-with-matches "$RGX_DISCHARGING" "$POWER_SUPPLY_BASE"/*/uevent
}
