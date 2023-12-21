function source-optional
{
  if [ -f "$1" ]
  then
    source "$1"
  fi
}

function git-clone-canonical
{
  local url="$1"
  command git-clone-canonical "$url" && \
    cd "$(command git-clone-canonical --show-path "$url")"
}
