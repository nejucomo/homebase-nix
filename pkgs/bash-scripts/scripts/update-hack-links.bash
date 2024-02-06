function main
{
  failures=0

  cd ~/hack

  for repo in $(find ~/src -type d -name .git | xargs dirname)
  do
    set-symlink "$repo" . || failures=(( "$failures" + 1 ))
  done

  exit "$failures"
}
