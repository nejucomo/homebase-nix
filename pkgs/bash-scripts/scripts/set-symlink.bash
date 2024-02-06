function main
{
  parse-args 'src dst' "$@"

  if [ -d "$dst" ]
  then
    dst="${dst}/$(basename "$src")"
  fi

  if [ -L "$dst" ]
  then
    actual="$(readlink "$dst")"

    if [ "$actual" = "$src" ]
    then
      log "$(vt100-disp "Already set: ${dst} -> ${src}" dim)"
    else
      fail "Cannot set ${dst} -> ${src}; it points elsewhere: ${dst} -> ${actual}"
    fi
  elif ! [ -e "$dst" ]
  then
    ln -sv "$src" "$dst"
  else
    fail "Cannot set ${dst} -> ${src}; it already exists: $(ls -ld "$dst")"
  fi
}
