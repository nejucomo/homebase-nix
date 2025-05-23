# helix: language=bash

# postlude.bash: useful behavior for bash scripts
#
# Usage:
#
# Bash scripts should source this file at the end. Note that aside
# from defining `SCRIPT_*` environment variables and defining functions,
# it also sets evaluation modes to be strict/safer.
#
# Installation:
#
# A manual installation places this file at a well-known path `P`, then
# all scripts must do `source $P`. This repository is a nix flake, so nix
# users can define this as a dependency of their own bash script flakes,
# and then use nix to determine the appropriate path.

set -efuo pipefail

# The absolute path of the script
SCRIPT_PATH="$(readlink -f "$0")"
# The name of the script
SCRIPT_NAME="$(basename "$SCRIPT_PATH")"
# The dir containing the script; may be useful for sourcing/invoking
# peer scripts, etc...
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"

PRELUDE_PATH="$(readlink -f "${BASH_SOURCE[0]}")"

# function: log [FLAGS] MESSAGE+
#
# Log the argument to stdout with a `$SCRIPT_NAME:` prefix.
# 
# - flags: if the first arg begins with `-` those flags are passed to
#          `echo`.
function log
{
    local flags=''
    while [ $# -gt 0 ] && [[ "$1" =~ ^- ]]
    do
        flags="${flags} $1"
        shift
    done

    echo $flags "${SCRIPT_NAME}: $*"
}

# function: log-run CMD ARG*
#
# Log the command, then execute it. The return value is the command exit
# status (or function return status).
function log-run
{
    log "running: $*"
    eval "$@"
    return $?
}

# function: log-error MESSAGE+
#
# Log the message to `stderr` with `$SCRIPT_NAME` and `error` prefix.
function log-error
{
    echo-err "$(vt100-disp "${SCRIPT_NAME} error: $*" yellow)"
}

# function: echo-err [FLAGS] MESSAGE+
#
# Echo to `stderr` with the `FLAGS` passed to `echo`. The `-e` flag is implied.
function echo-err
{
    echo -e "$@" 1>&2
}

# function: fail MESSAGE+
#
# Log `MESSAGE` words to `stderr` with a `$SCRIPT_NAME` & `error` prefix,
# then exit with status 1.
function fail
{
    log-error "$*"
    exit 1
}

# function: parse-args VAR_SPECS [VALUE]*
#
# Assign the respective `VALUE` args to the global variable names specified in `VAR_SPECS`. If assignment fails to match the specification in `VAR_SPECS`, a usage error is shown then the script exits.
#
# `VAR_SPECS` must be a space separated of "spec" fields. Each spec is a variable name, optionally followed by `=<default value>` (with no spaces), except the final spec may be `*` followed by an array name.
#
# If a spec specifies a default value, then every spec which occurs after that must also specify a default value, unless it is the final `*<name>` spec.
#
# Parsing proceeds by assigning the parameters in `VALUE` to the variables defined in `VAR_SPECS`. If a final `*<name>` spec is provided, then `name` becomes an array capturing 0 or more final parameters. If parameters are not present for variables with a default in their spec, those variables are assigned the default value.
#
# # Errors
#
# If an error is detected, a usage error is passed to `fail`.
#
# Error cases:
# - a spec which lacks a default definition is not assigned a parameter value
# - there is no final `*<name>` spec, but more parameters are present than the number of specs
#
# # Example 1
#
# ```
# $ parse-args 'x y z=blah' foo bar
# $ echo $x
# foo
# $ echo $z
# blah
# ```
#
# # Example 2
#
# ```
# $ parse-args 'x y=yeet *extra' foo
# $ echo $x
# foo
# $ echo $y
# yeet
# $ echo "${#extra[@]}"
# 0
# ```
#
# # Example 3
#
# ```
# $ parse-args 'x y=yeet *extra' a b c d e f
# $ echo $x
# a
# $ echo $y
# b
# $ echo "${#extra[@]}"
# 4
# ```
function parse-args
{
    local varnames="$1"; shift
    local defaults_section='false'
    local starvar=''

    for varspec in $varnames
    do
        if [ -n "$starvar" ]
        then
            fail "Disallowed varspec after '*${starvar}': ${varspec}"
        elif [[ "$varspec" =~ ^\*[A-Za-z0-9_]+$ ]]
        then
            starvar="$(echo $varspec | sed 's/^\*//')"
        elif echo "$varspec" | grep -q '='
        then
            defaults_section='true'
        elif [ "$defaults_section" = 'true' ]
        then
            fail "Missing default value: $varspec"
        fi

        if [ -n "$starvar" ]
        then
            declare -ga "${starvar}=(\"\$@\")"
            set --
        else
            case "$defaults_section"
            in
                false)
                    [ $# -gt 0 ] || fail "Missing argument: $varspec"
                    declare -g "$varspec=$1"
                    shift
                    ;;
                true)
                    local parse_args_value="$(echo "$varspec" | sed 's|^.*=||')"
                    if [ $# -gt 0 ]
                    then
                        parse_args_value="$1"
                        shift
                    fi
                    varspec="$(echo "$varspec" | sed 's|=.*$||')"
                    declare -g "$varspec=$parse_args_value"
                    ;;
                *)
                    fail "internal invariant failed \$defaults_section=$defaults_section"
            esac
        fi
    done

    [ $# -eq 0 ] || fail "Unexpected arguments: $*"
}

# Generic VT100 display attributes:
function vt100-disp
{
    parse-args 'content *escapes' "$@"

    for esc in "${escapes[*]}"
    do
        vt100-disp-attr-escape "$esc"
    done
    echo -ne "$content"
    vt100-disp-attr-escape 'reset'
}

function vt100-disp-attr-escape
{
    parse-args 'attrname' "$@"
    echo -en "\033[$(vt100-disp-attr-code "${attrname}")m"
}

function vt100-disp-attr-code
{
    parse-args 'attrname' "$@"
    case "$attrname"
    in
        reset) echo 0 ;;
        bright) echo 1 ;;
        dim) echo 2 ;;
        underscore) echo 4 ;;
        blink) echo 5 ;;
        reverse) echo 7 ;;
        hidden) echo 8 ;;
        black) echo 30 ;;
        red) echo 31 ;;
        green) echo 32 ;;
        yellow) echo 33 ;;
        blue) echo 34 ;;
        magenta) echo 35 ;;
        cyan) echo 36 ;;
        white) echo 37 ;;
        bg_black) echo 40 ;;
        bg_red) echo 41 ;;
        bg_green) echo 42 ;;
        bg_yellow) echo 43 ;;
        bg_blue) echo 44 ;;
        bg_magenta) echo 45 ;;
        bg_cyan) echo 46 ;;
        bg_white) echo 47 ;;
        *) fail "Unknown vt100 display attribute name: $attrname"
    esac
}


# If `HOMEBASE_DEBUG` is not the empty string, then enable xtrace:
if [ -n "${HOMEBASE_DEBUG:-}" ]
then
    echo-err '[homebase debug enabled]'
    set -x
fi
main "$@"
exit $?
