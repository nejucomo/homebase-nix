# Search-And-Replace

function main
{
  parse-args 'glob pat repl' "$@"
  find . -type f -name "$glob" -exec sed -i "s/${pat}/${repl}/g" '{}' \;

  if [ "$glob" = '*.rs' ]
  then
    cargo fmt
  fi
}
