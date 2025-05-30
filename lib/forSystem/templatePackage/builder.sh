source "$stdenv/setup"

set -efuo pipefail

TMPL_EXT='homebase-template'
PARAMSFILE='./homebase-template.json'

function main
{
  local outpkg="$out/hbpkg/$name"
  local outinst="$out/$reldst"

  mkdir -p "$outpkg"
  mkdir -p "$outinst"

  echo "$HOMEBASE_TEMPLATE_JSON" > "$PARAMSFILE"

  expand-package "$src" "$outpkg"
  link-package "$outpkg" "$outinst"
}

function expand-package
{
  check-arg-count 2 $#
  local src="$1"
  local out="$2"

  if [ -f "$src" ]
  then
    expand-file "$src" "$outpkg"
  elif [ -d "$src" ]
  then
    expand-dir "$src" "$outpkg"
  else
    fail-fs-type "$src" "$out"
  fi
}

# Note: This assumes all single-file packages are scripts:
function expand-file
{
  check-arg-count 2 $#
  local src="$1"
  local out="$2"

  local name="$(echo "$src" | sed 's|^/nix/store/[^-]*-||')"

  local newsrc='./newsrc'
  local newbin="${newsrc}/bin/${name}.${TMPL_EXT}"

  mkdir -p "$(dirname "$newbin")"
  cp "$src" "$newbin"
  chmod u+x "$newbin"

  expand-dir "$newsrc" "$out"
}

function expand-dir
{
  check-arg-count 2 $#
  local src="$1"
  local out="$2"

  for p in $(find "$src" -mindepth 1)
  do
    relp="$(echo "$p" | sed "s|^${src}/||")"
    outp="$out/$relp"
    if [ -f "$p" ]
    then
      stem="$(template-out-path "$outp")"
      if [ "$stem" = "$outp" ]
      then
        # Normal file:
        cp "$p" "$outp"
      else
        # Template:
        minijinjify "$p" "$stem"
      fi
    elif [ -d "$p" ]
    then
      mkdir -p "$outp"
    else
      fail-fs-type "$p"
    fi
  done
}

function link-package
{
  check-arg-count 2 $#
  local outpkg="$1"
  local outinst="$2"

  if [ -d "$outinst" ]
  then
    for p in $(find "$outpkg" -mindepth 1 -maxdepth 1)
    do
      ln -sv "$p" "$outinst"
    done
  else
    ln -sv "$outpkg" "$outinst"
  fi
}

function fail
{
  echo "fail: $*"
  exit -1
}

function check-arg-count
{
  if [ "$1" -ne "$2" ]
  then
    fail "internal error: expected $1 args, received $2"
  fi
}

function fail-fs-type
{
  check-arg-count 1 $#
  fail "cannot handle non-file, non-directory: $1"
}

function template-out-path
{
  check-arg-count 1 $#
  echo "$1" | sed "s|\\.${TMPL_EXT}\$||"
}

function minijinjify
{
  check-arg-count 2 $#
  local input="$1"
  local output="$2"

  echo "Expanding template into: $output"

  minijinja-cli \
    --format json \
    --autoescape none \
    --strict \
    --no-include \
    --output "$output" \
    "$input" \
    "$PARAMSFILE"

  chmod \
    --reference="$(readlink -f "$input")" \
    "$output"
}

main "$@"
