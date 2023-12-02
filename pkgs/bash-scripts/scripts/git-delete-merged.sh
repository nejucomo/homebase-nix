for branch in $(git branch --merged | sed 's|^[* ] ||' | grep -Eve '^(master|main|dev)$')
do
    git branch -d "$branch"
done
