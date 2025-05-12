function main
{
  parse-args 'remote=upstream' "$@"

  exec git push "$remote" "$(git current-branch)"
}
