source "$stdenv/setup"

set -efuo pipefail

PARAMSFILE='./homebase-template.json'

function log-run
{
  echo "Running: $*"
  eval "$@"
}

mkdir "$out"

echo 'Template params:'

echo "$HOMEBASE_TEMPLATE_JSON" | tee $PARAMSFILE | jq

for p in $(find "$src" -mindepth 1)
do
  relp="$(echo "$p" | sed "s|^${src}/||")"
  outp="$out/$relp"
  if [ -f "$p" ]
  then
    stem="$(echo "$outp" | sed 's|\.homebase-template$||')"
    if [ "$stem" = "$outp" ]
    then
      # Normal file:
      cp "$p" "$outp"
    else
      # Template:
      log-run minijinja-cli \
        --format json \
        --autoescape none \
        --strict \
        --no-include \
        --output "$stem" \
        "$p" \
        "$PARAMSFILE"

      chmod \
        --reference="$(readlink -f "$p")" \
        "$stem"
    fi
  elif [ -d "$p" ]
  then
    mkdir "$outp"
  else
    echo 'not a file or dir:' "$p"
    exit 1
  fi
done
