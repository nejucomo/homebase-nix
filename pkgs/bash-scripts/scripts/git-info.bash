function main
{
  git rev-parse --is-inside-work-tree > /dev/null 
  
  echo "-> branch: $(git current-branch)"

  git glog -5 | sed 's/^/ /; s/^fatal:/!!/' || true

  echo
  git status --porcelain
}
