function main
{
  parse-args 'dest' "$@"
  git branch-append jump
  git reset --hard "$dest"
}
