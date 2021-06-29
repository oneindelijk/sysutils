#!/bin/bash

# clean up NotIncluded aliases
alias | grep -i toolnotincluded | while read aliasline
do
    aliaskw=${aliasline%%=*}
    printf "Unaliasing %s\n" "${aliaskw}"
    unalias ${aliaskw}
done
