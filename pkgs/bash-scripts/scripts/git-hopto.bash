function main
{
  parse-args 'dest' "$@"
  git branch-append pre-hop
  git reset --hard "$dest"
}
