#!/usr/bin/env bash
set -e

export TB_VERSION_WARNING=0
export VERSION=$1

run_test() {
    t=$1
    echo "** Running $t **"
    # Check if VERSION is provided
    if [[ -n $VERSION ]]; then
        echo "VERSION found: $VERSION for test $t"
        sed -i "s/tb/tb --semver $VERSION/" $t
    else
        echo "VERSION not found for test $t"
    fi
    echo "** Contents of $t after modification (if any):"
    cat $t
    tmpfile=$(mktemp)
    if bash $t $2 >$tmpfile; then
        if diff -B ${t}.result $tmpfile; then
            echo "Test $t: OK";
        else
            echo "Test $t failed, diff:";
            diff -B ${t}.result $tmpfile
            cat $tmpfile
            rm $tmpfile
            return 1
        fi
    else
        echo "Error: Test $t failed with bash command exit code $?"
        cat $tmpfile
        rm $tmpfile
        return 1
    fi
    rm $tmpfile
    echo ""
}
export -f run_test

fail=0
find ./tests -name "*.test" -print0 | xargs -0 -I {} -P 4 bash -c 'run_test "$@"' _ {} $VERSION || fail=1

if [ $fail == 1 ]; then
  exit -1;
fi
