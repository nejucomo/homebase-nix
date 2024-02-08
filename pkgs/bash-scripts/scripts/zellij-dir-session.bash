function main
{
    parse-args "dir=$(pwd)" "$@"
    session="$(basename "$dir")"
    mkdir -p "$dir"
    cd "$dir"
    zellij --session "$session" --layout edit
}
