function main
{
    parse-args "dir=$(pwd)" "$@"
    session="$(basename "$dir")"
    mkdir -p "$dir"
    cd "$dir"
    tmux new-session -At "$session"
}
