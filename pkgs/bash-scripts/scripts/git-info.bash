function main
{
  git rev-parse --is-inside-work-tree
  
	echo -e "= branch: $(git current-branch)\n"

	git glog -5 || true

  echo -e '\n'

  git status --porcelain
}
