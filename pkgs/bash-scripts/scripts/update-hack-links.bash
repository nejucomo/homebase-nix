function main
{
  cd ~/hack
  find ~/src -type d -name .git | xargs dirname | xargs -i set-symlink '{}' .
}
