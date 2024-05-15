function main
{
  parse-args 'branch=.' "$@"

  if [ "$branch" = '.' ]
  then
    branch="$(git remote | head -1)"
  fi

  exec git push "$branch" "$(git current-branch)"
}
