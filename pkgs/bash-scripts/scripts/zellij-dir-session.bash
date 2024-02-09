function main
{
    parse-args "dir=$(pwd)" "$@"
    session="$(basename "$dir")"
    mkdir -p "$dir"
    cd "$dir"

    if [ -z "${ZELLIJ-:}" ]
    then
        zellij attach --create "$session"
    else
        alacritty --command zellij attach --create "$session" &
    fi
}
