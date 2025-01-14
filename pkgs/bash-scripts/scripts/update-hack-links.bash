function main
{
  failures=0

  cd ~/hack

  for repo in $(find ~/src -type d -name .git | xargs dirname)
  do
    reponame="$(basename "$repo")"
    slug="$(basename "$(dirname "$repo")")"
    set-symlink "${repo}" "./${reponame}.${slug}" || failures=$(( "$failures" + 1 ))
    set-symlink "./${reponame}.${slug}" "./${reponame}"
  done

  exit "$failures"
}
