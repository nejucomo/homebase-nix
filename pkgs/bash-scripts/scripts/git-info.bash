function main
{
  git rev-parse --is-inside-work-tree > /dev/null 
  
	echo "-> branch: $(git current-branch)"

	git glog -5 | sed 's/^/ /' || true

  git status --porcelain 2>&1 | sed 's/^fatal:/!!/'
}
