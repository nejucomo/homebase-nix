function main {
  parse-args 'period cmd' "$@"

  while run-cmd "$cmd" || true
  do
    sleep "$period"
    echo
  done
}

function run-cmd {
  echo "$(vt100-disp "$(date --iso=s) $SCRIPT_NAME" dim) $(vt100-disp "$cmd" blue)"
  bash -c "$cmd"
}
