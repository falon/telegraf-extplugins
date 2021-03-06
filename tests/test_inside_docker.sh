#!/bin/bash 

function travis_test {
    local ARGUMENTS=
    PROGNAME="$1"
    PROG=$2
    for (( i=3; i <= "$#"; i++ )); do
        ARGUMENTS="$ARGUMENTS ${!i}"
    done
    echo -en "=======\n\n\e[96m$PROGNAME\e[0m $PROG $ARGUMENTS\n\n" >> $LDIR/test.log
    echo $ARGUMENTS | xargs $PROG >> $LDIR/test.log 2>&1
    local status=$?
    if [ $status -ne 0 ]; then
        printf "%-40s\t[\e[31;5m  %s  \e[0m]\n" "$PROGNAME" FAIL
	echo -e "\e[31mExit Status: $status\e[0m" >> $LDIR/test.log
    else
        printf "%-40s\t[\e[32m  %s  \e[0m]\n" "$PROGNAME" OK
	echo -e "\e[32mExit Status: $status\e[0m" >> $LDIR/test.log
    fi
    return $status
}


LDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
> $LDIR/test.log
status=0
IFS=";"
echo -en "\n\n ANSIBLE ROLE TESTS\n\n"
while read test || [ -n "$test" ]; do
	travis_test $test
	status=$(($status + $?))
done < $LDIR/TESTLIST

# Return the exit test for Travis verdict
exit $status
