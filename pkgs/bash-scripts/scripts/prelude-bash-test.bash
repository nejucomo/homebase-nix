set +e

SUCCESSES=0
FAILURES=0

function main
{
    test-parse-args positive no-args ''
    test-parse-args negative no-args-unexpected '' 'foo' 'bar'

    test-parse-args positive one-arg 'x' '42'
    test-parse-args negative one-arg-missing 'x'
    test-parse-args negative one-arg-unexpected 'x' '42' 'unexpected'

    test-parse-args positive two-args 'x y' '42' 'life-the-universe-and-everything'
    test-parse-args negative two-args-missing 'x y' '42'
    test-parse-args negative two-args-unexpected 'x y' '42' '17' '23'

    test-parse-args positive two-args-one-default-not-provided 'x y=7' '42'
    test-parse-args positive two-args-one-default-provided 'x y=7' '42' 'woot'
    test-parse-args negative two-args-one-default-missing 'x y=7'
    test-parse-args negative two-args-one-default-unexpected 'x y=7' 'a' 'b' 'c'
    test-parse-args negative internally-invalid-default-specification 'x y=7 z' 'a' 'b' 'c'

    test-parse-args positive star-args-captures-none 'x *y' '42'
    test-parse-args positive star-args-captures-four 'x *y' '42 a b c d'

    test-parsed-default-args

    test-parse-args-example-one
    test-parse-args-example-two
    test-parse-args-example-three

    exit-with-results
}

function test-parse-args
{
    local posneg="$1"; shift
    case "$posneg"
    in
        positive|negative) ;;
        *) fail "internal invariant failure: \$posneg=$posneg"
    esac

    log -n "test-parse-args $1... "; shift
    (
        parse-args "$@"
    ) > /dev/null 2>&1
    local result="$?"

    [ "$posneg" = 'negative' ] && result=$(( ! $result ))

    if [ "$result" -eq 0 ]
    then pass-test
    else fail-test
    fi
}

function test-parsed-default-args
{
    log -n 'Checking parsed default value... '
    parse-args 'x y=7' 42
    if [ $x -eq 42 -a $y -eq 7 ]
    then pass-test
    else fail-test
    fi

    log -n 'Checking parsed provided (over default) value... '
    parse-args 'x y=7' 7 'woot'
    if [ $x -eq 7 -a $y = 'woot' ]
    then pass-test
    else fail-test
    fi
}

function test-parse-args-example-one
{
    log "$FUNCNAME"
    outdir="$(mktemp -d "${SCRIPT_NAME}-data.XXX")"

    (
        parse-args 'x y z=blah' foo bar
        echo $x
        echo $z
    ) > "$outdir/actual" 2>&1

    sed 's|^      ||' > "$outdir/expected" <<____EOF
      foo
      blah
____EOF

    if diff -u "$outdir/expected" "$outdir/actual"
    then pass-test
    else fail-test
    fi
}

function test-parse-args-example-two
{
    log "$FUNCNAME"
    outdir="$(mktemp -d "${SCRIPT_NAME}-${FUNCNAME}-data.XXX")"

    (
      parse-args 'x y=yeet *extra' foo
      echo $x
      echo $y
      echo "${#extra[@]}"
    ) > "$outdir/actual" 2>&1

    sed 's|^      ||' > "$outdir/expected" <<____EOF
      foo
      yeet
      0
____EOF

    if diff -u "$outdir/expected" "$outdir/actual"
    then pass-test
    else fail-test
    fi
}

function test-parse-args-example-three
{
    log "$FUNCNAME"
    outdir="$(mktemp -d "${SCRIPT_NAME}-${FUNCNAME}-data.XXX")"

    (
       parse-args 'x y=yeet *extra' a b c d e f
       echo $x
       echo $y
       echo "${#extra[@]}"
    ) > "$outdir/actual" 2>&1

    sed 's|^      ||' > "$outdir/expected" <<____EOF
       a
       b
       4
____EOF

    if diff -u "$outdir/expected" "$outdir/actual"
    then pass-test
    else fail-test
    fi
}

function pass-test
{
    echo 'ok'
    SUCCESSES="$(expr "$SUCCESSES" + 1)"
}

function fail-test
{
    echo 'FAIL'
    FAILURES="$(expr "$FAILURES" + 1)"
}

function exit-with-results
{
    sed 's|^      ||' <<____EOF

      Tests finished with $SUCCESSES successes and $FAILURES failures.
____EOF
    exit $FAILURES
}
