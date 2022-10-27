#!/bin/bash

sed -i 's/a/A/g' $(find $1 -type f)