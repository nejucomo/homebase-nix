function main
{
    parse-args 'dir=.' "$@"
    dir="$(readlink -f "$dir")"
    session="$(basename "$dir")"
    mkdir -p "$dir"
    cd "$dir"
    tmux new-session -At "$session"
}

main "$@"
