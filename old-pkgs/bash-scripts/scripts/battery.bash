DEV_PREFIX='/sys/class/power_supply'

function main
{
  parse-args 'DEVICE=BAT1' "$@"

  show-charge "${DEV_PREFIX}/${DEVICE}"
}

function show-charge
{
  parse-args 'dev' "$@"
  echo $(( $(cat "$dev/charge_now") * 100 / $(cat "$dev/charge_full") ))
}
