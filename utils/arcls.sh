#!/bin/bash
set -euo pipefail
IFS=$'\n\t'
# Bash strict mode

if [[ $# -lt 2 ]]
then 
    echo "Usage: ./mapextractor.sh \"/path/to/ARCtool\" \"/path/to/Dragon's Dogma Online\""
fi

cd "$(dirname "$0")"

echo "arc,file" > arcls.out.csv

# Copy map files and list them
for arc in "$2"/*/**/*.arc
do
    echo "Listing files in $arc"

    # Generate arc contents list
    "$1" -ddo -pc -tex -v 7 -l "$arc"

    for file in $(sed -n "s/Path\=\(.*\)/\1/p" "$arc.verbose.txt")
    do
        echo "$arc,$file" >> arcls.out.csv
    done

    # Clean up
    rm "$arc.verbose.txt"
done

# Clean up
rm log.txt