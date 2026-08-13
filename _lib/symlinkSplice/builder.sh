set -eu

function main
{
  mkdir "$out"

  for root in $(echo "$roots" | sed 's|:| |g')
  do
    echo "splicing root $root"
    splice "$out" "$root"
  done
}

function splice
{
  check-arg-count 2 $#
  local dst="$1"
  local src="$2"

  # echo "splicing $dst <- $src"

  if [[ "$src" =~ ^.*/nix-support ]]
  then
    # Black hole all `.../nix-support`! This should be safe only for top-level homebase package
    return 0
  elif ! [ -e "$dst" ]
  then
    ln -s "$src" "$dst"
  elif [ -L "$dst" ]
  then
    resplice "$dst" "$src"
  elif [ -d "$dst" ] && [ -d "$src" ]
  then
    splice-from-dir-into-dir "$dst" "$src"
  else
    fail 'unhandled case for these path types' "$dst" "$src"
  fi
}

function splice-from-dir-into-dir
{
  check-arg-count 2 $#
  local dest="$1"
  local src="$2"

  [ -d "$src" ] || fail 'expected dir, found non-dir:' "$src"

  for subsrc in $(dir-children "$src")
  do
    local name="$(basename "$subsrc")"
    local subdest="$dest/$name"
    splice "$subdest" "$subsrc"
  done
}

function resplice
{
  check-arg-count 2 $#
  local dst="$1"
  local srca="$2"

  local srcb="$(readlink "$dst")"

  if [ "$srca" = "$srcb" ]
  then
    # noop
    return 0
  elif [ -d "$srca" ] || [ -d "$srcb" ]
  then
    resplice-dir "$dst" "$srca" "$srcb"
  else
    splice-mangled "$dst" "$srca"
  fi
}

function splice-mangled
{
  check-arg-count 2 $#
  local dst="$1"
  local src="$2"

  local n=0
  local newdst="$dst.$n"

  while [ -e "$newdst" ]
  do
    n=$(( $n + 1 ))
    newdst="$dst.$n"
  done

  echo "Mangling collision to: $newdst"
  ln -s "$src" "$newdst"
}

function resplice-dir
{
  check-arg-count 3 $#
  local dst="$1"
  local srca="$2"
  local srcb="$3"

  echo "resplicing dir $dst"

  # echo "resplice $dst"
  rm "$dst"
  mkdir "$dst"
  splice-from-dir-into-dir "$dst" "$srca"
  splice-from-dir-into-dir "$dst" "$srcb"
}

function dir-children
{
  check-arg-count 1 $#
  local d="$1"

  find "$d" -mindepth 1 -maxdepth 1
}

function check-arg-count
{
  local expected="$1"
  local found="$2"
  if ! [ "$expected" -eq "$found" ]
  then
    fail "Wrong arg count. Expecting $expected args; found $found."
  fi
}

function fail
{
  echo "FAIL: $1"
  shift
  if [ $# -gt 0 ]
  then
    ls -ld "$@"
  fi
  exit -1
}

main "$@"
