# Search-And-Replace

function main
{
  git-action git-is-clean || fail 'Git working tree is not clean.'

  parse-args 'glob pat repl' "$@"
  find . -type f -name "$glob" -exec sed -i "s/${pat}/${repl}/g" '{}' \;

  if [ "$glob" = '*.rs' ]
  then
    cargo fmt
  fi
  git-action git commit --all --edit -m "'Search-and-Replace \"$pat\" with \"$repl\" in \"$glob\".'"
}

function git-action
{
  if [ -z "${SAR_NO_GIT:-}" ]
  then
    eval "$@"
  fi
}
