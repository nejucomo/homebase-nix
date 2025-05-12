function main
{
  parse-args 'branch' "$@"
  git branch | sed 's/^. //' | grep -q "^${branch}$"
}
