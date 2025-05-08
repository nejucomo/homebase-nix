function main
{
  local repohook="${GIT_DIR}/hooks/post-commit"

  local status=0
  if [ -x "$repohook" ]
  then
    set +e
    eval "$repohook" "$@"
    status=$?
    set -e
  fi

  git info
  return "$status"
}
