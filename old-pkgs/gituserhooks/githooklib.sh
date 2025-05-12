# This requires postlude to be sourced, ie source this within `main`
export REPO_HOOK="${GIT_DIR}/hooks/${SCRIPT_NAME}"

function run-repo-hook
{
  [ -x "$REPO_HOOK" ] || return 0

  log-run "$REPO_HOOK" "$@"
  return $?
}
