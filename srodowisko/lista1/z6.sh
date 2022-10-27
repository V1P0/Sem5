#!/bin/bash

for WORD in $(for FILE in $(find $1 -type f);
                do
                    cat $FILE | tr '[A-Z]' '[a-z]' | tr ' \t' '\n\n' | sed -e "/^$/d" | sort | uniq ;
                done | sort | uniq)
    do
    A=$(grep -H -n -r -i -E "^$WORD ([a-zA-Z ]* )*$WORD |^$WORD ([a-zA-Z ]* )*$WORD$| $WORD ([a-zA-Z ]* )*$WORD | $WORD ([a-zA-Z ]* )*$WORD$" $1)
    if [ -n "$A" ]; then
        echo "$WORD:"
        echo $A
    fi
    done