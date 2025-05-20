source "$stdenv/setup"

set -efuo pipefail

function log-run
{
  echo "Running: $*"
  eval "$@"
}

mkdir "$out"
for p in $(find "$src")
do
  relp="$(echo "$p" | sed "s|^$src||")"
  outp="$out/$relp"
  if [ -f "$p" ]
  then
    stem="$(echo "$outp" | sed 's|\.homebase-template||')"
    if [ "$stem" = "$outp" ]
    then
      # Normal file:
      cp "$p" "$outp"
    else
      # Template:
      log-run minijinja \
        --format json \
        --autoescape none \
        --strict \
        --no-include \
        --output "$outp" \
        "$p" \
        "$envFile"
    fi
  elif [ -d "$src" ]
  then
    mkdir "$outp"
  else
    echo 'not a file or dir:' "$src"
    exit 1
  fi
done
