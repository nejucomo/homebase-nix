function main
{
	git rev-parse --abbrev-ref HEAD 2> /dev/null \
	  | sed "s/^HEAD$/$(git config init.defaultBranch)/"
}
