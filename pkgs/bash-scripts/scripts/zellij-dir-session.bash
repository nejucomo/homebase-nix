function main
{
    parse-args "dir=$(pwd)" "$@"
    session="$(basename "$dir")"
    mkdir -p "$dir"
    cd "$dir"

    if [ -n "${ZELLIJ-:}" ] && xhost >& /dev/null
    then
        alacritty --command zellij attach --create "$session" &
    else
        zellij attach --create "$session"
    fi
}
