function main
{
  (
    cd "$(mktemp --directory --tmpdir "${SCRIPT_NAME}.XXX")"
    exec "$SHELL" "$@"
  )
}
