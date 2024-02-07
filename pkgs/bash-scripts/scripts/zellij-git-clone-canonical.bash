function main
{
  parse-args 'url' "$@"

  git-clone-canonical "$url"
  zellij-dir-session "$(git-clone-canonical --show-path "$url")"
}
