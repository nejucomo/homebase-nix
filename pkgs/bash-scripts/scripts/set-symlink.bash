function main
{
  parse-args 'target link_name' "$@"

  if [ -L "$link_name" ]
  then
    actual="$(readlink "$link_name")"

    if [ "$actual" = "$target" ]
    then
      log "$(vt100-disp "Already set: ${link_name} -> ${target}" dim)"
    else
      fail "Cannot set ${link_name} -> ${target}; it points elsewhere: ${link_name} -> ${actual}"
    fi
  elif ! [ -e "$link_name" ]
  then
    log "Setting: ${link_name} -> ${target}"
    ln --no-target-directory -s "$target" "$link_name"
  else
    fail "Cannot set ${link_name} -> ${target}; it already exists: $(ls -ld "$link_name")"
  fi
}
