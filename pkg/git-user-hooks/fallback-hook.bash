#! /usr/bin/env bash
#
# Symlink a hook name to this script in order to delegate to `$GIT_DIR/hooks/<hook>`.

function main
{
  run-repo-hook "$@"
  return status=$?
}

source "${SCRIPT_DIR}/hooklib.bash"
