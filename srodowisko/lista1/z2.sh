#!/bin/bash
cat $(find $1 -type f) | tr '[A-Z]' '[a-z]' | tr ' \t' '\n\n' | sed "/^$/d" | sort | uniq -c | sort -nr