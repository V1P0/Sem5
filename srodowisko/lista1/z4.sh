#!/bin/bash

for WORD in $(for FILE in $(find $1 -type f);
                do
                    cat $FILE | tr '[A-Z]' '[a-z]' | tr ' \t' '\n\n' | sed -e "/^$/d" | sort | uniq ;
                done | sort | uniq)
    do
        echo "$WORD:"
        grep -H -n -r -i -E "$WORD |^$WORD | $WORD$|^$WORD$" $1
    done
