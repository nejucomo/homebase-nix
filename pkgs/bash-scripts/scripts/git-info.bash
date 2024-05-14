function main
{
  git rev-parse --is-inside-work-tree > /dev/null 
  
  echo "-> branch: $(git current-branch)"
  echo

  git glog -5 2>&1 | sed 's/^/ /; s/^fatal:/!!/; s/ *$//' || true

  echo -e '\n'
  git status --porcelain
}
