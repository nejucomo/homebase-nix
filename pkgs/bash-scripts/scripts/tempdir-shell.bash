function main
{
  D="$(mktemp --directory --tmpdir "${SCRIPT_NAME}.XXX")"
  ( 
    cd "$D"
    exec "$SHELL" "$@"
  )
  log-run rm -rf "$D"
}
