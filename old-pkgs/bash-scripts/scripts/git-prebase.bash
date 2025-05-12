function main
{
  git branch-append 'prebase'
  git rebase "$@"
}
