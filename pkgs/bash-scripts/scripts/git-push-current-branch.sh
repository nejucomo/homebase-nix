function main
{
  parse-args 'branch=upstream' "$@"
  exec git push "$branch" "$(git current-branch)"
}

main "$@"
