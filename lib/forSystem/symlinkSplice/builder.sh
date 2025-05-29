function main
{
  mkdir "$out"

  while [ -n "$roots" ]
  do
    root="$(echo "$roots" | sed 's|:.*$||')"
    splice-from-dir-into-dir "$out" "$root"

    roots="$(echo "$roots" | sed 's|^[^:]*:||')"
  done
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

function splice
{
  check-arg-count 2 $#
  local dst="$1"
  local src="$2"

  if ! [ -e "$dst" ]
  then
    ln -s "$src" "$dst"
  elif [ -L "$dst" ]
  then
    if [ -d "$dst" ]
    then
      resplice "$dst" "$src"
    else
      fail 'Cannot resplice non-dir:' "$dst" "$src"
    fi
  elif [ -d "$dst" ] && [ -d "$src" ]
  then
    splice-from-dir-into-dir "$dst" "$src"
  else
    fail 'unhandled case for these path types' "$dst" "$src"
  fi
}

function resplice
{
  check-arg-count 2 $#
  local dst="$1"
  local srca="$2"
  local srcb="$(readlink "$dst")"
  echo "resplice $dst <- [ $srca, $srcb ]"
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
