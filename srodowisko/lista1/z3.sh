#!/bin/bash

for FILE in $(find $1 -type f);
	do
		cat $FILE | tr '[A-Z]' '[a-z]' | tr ' \t' '\n\n' | sed -e "/^$/d" | sort | uniq ;
	done | sort | uniq -c