function source-optional
{
  if [ -f "$1" ]
  then
    source "$1"
  fi
}
