function main
{
  if [ $(git status --porcelain | wc -l) -eq 0 ]
  then
    # clean
    exit 0
  else
    # dirty
    exit 1
  fi
}
