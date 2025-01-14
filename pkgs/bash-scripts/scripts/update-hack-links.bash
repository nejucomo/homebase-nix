function main
{
  failures=0

  cd ~/hack

  for repo in $(find ~/src -type d -name .git | xargs dirname)
  do
    reponame="$(basename "$repo")
    if ! set-symlink "$repo" "./${reponame}"
    then
      # See if we can add a disambiguation slug:
      slug="$(basename "$(dirname "$repo")")"
      set-symlink "${repo}.${slug}" "./${reponame}" || failures=$(( "$failures" + 1 ))
    fi
  done

  exit "$failures"
}
