# prelude.bash: useful behavior for bash scripts
#
# Usage:
#
# Bash scripts should source this file at the beginning. Note that aside
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

# function: log [FLAGS] MESSAGE+
#
# Log the argument to stdout with a `$SCRIPT_NAME:` prefix.
# 
# - flags: if the first arg begins with `-` those flags are passed to
#          `echo`.
function log
{
    local flags=''
    while [ $# -gt 0 ] && [[ "$1" == -* ]]
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
    echo-err "${SCRIPT_NAME} error: $*"
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

# function: parse-args VAR_NAMES [VALUE]*
#
# Assign the respective `VALUE` args to the global variable names
# specified in `VAR_NAMES`. If assignment fails to match the specification
# in `VAR_NAMES`, a usage error is shown then the script exits.
#
# `VAR_NAMES` must be a space separated of `<var spec>` fields.
# Each `<var spec>` is a variable name, optionally followed by
# `=<default value>` (with no spaces).
#
# If a `<var spec>` specifies a default value, then every `<var spec>`
# which occurs after that must also specify a default value.
#
# If the number of `VALUE` args is no less than the number of `<var spec>`
# definitions without defaults, and it is also no more than the number of
# total `<var spec>` definitions, then parsing succeeds. Otherwise,
# parsing fails and a usage error is displayed and the process exits.
#
# If parsing succeeds, then each variable named in `<var spec>` is
# assigned a value from the `VALUE` args, unless there are move `<var spec>`
# definitions than `VALUE` args, in which case, the defaults are assigned.
#
# # Example:
#
# ```
# $ parse-args 'x y z=blah' foo bar
# $ echo $x
# foo
# $ echo $z
# blah
# ```
function parse-args
{
    local varnames="$1"; shift
    local defaults_section='false'

    for parse_args_varname in $varnames
    do
        if echo "$parse_args_varname" | grep -q '='
        then
            defaults_section='true'
        elif [ "$defaults_section" = 'true' ]
        then
            fail "Missing default value: $parse_args_varname"
        fi

        case "$defaults_section"
        in
            false)
                [ $# -gt 0 ] || fail "Missing argument: $parse_args_varname"
                declare -g "$parse_args_varname=$1"
                shift
                ;;
            true)
                local parse_args_value="$(echo "$parse_args_varname" | sed 's|^.*=||')"
                if [ $# -gt 0 ]
                then
                    parse_args_value="$1"
                    shift
                fi
                parse_args_varname="$(echo "$parse_args_varname" | sed 's|=.*$||')"
                declare -g "$parse_args_varname=$parse_args_value"
                ;;
            *)
                fail "internal invariant failed \$defaults_section=$defaults_section"
        esac
    done

    [ $# -eq 0 ] || fail "Unexpected arguments: $*"
}

# If `HOMEBASE_DEBUG` is not the empty string, then enable xtrace:
if [ -n "${HOMEBASE_DEBUG:-}" ]
then
    echo-err '[yadots debug enabled]'
    set -x
fi
