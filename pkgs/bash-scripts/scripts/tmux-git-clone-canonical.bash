function main
{
  parse-args 'url' "$@"

  git-clone-canonical "$url"
  tmux-dir-session "$(git-clone-canonical --show-path "$url")"
}
