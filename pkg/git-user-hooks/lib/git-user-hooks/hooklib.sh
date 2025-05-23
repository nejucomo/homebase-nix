function repo-hook
{
  echo "$(git rev-parse --git-dir)/hooks/${SCRIPT_NAME}"
}

function run-repo-hook
{
  local hook="$(repo-hook)"

  [ -x "$hook" ] || return 0

  log-run "$hook" "$@"
  return $?
}
