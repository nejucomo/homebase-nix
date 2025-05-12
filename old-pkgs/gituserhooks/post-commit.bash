function main
{
  source "${SCRIPT_DIR}/githooklib.sh"

  run-repo-hook "$@"
  local status=$?
  
  log-run git info
  return "$status"
}
