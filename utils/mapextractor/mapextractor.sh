#!/bin/bash
set -euo pipefail
IFS=$'\n\t'
# Bash strict mode

if [[ $# -lt 2 ]]
then 
    echo "Usage: ./mapextractor.sh \"/path/to/ARCtool\" \"/path/to/Dragon's Dogma Online\""
fi

cd "$(dirname "$0")"

mkdir -p icons
mkdir -p results
mkdir -p tmp
cd tmp

# Copy item icon files and unpack them
for arc in "$2"/nativePC/rom/ui/00_common/Item/*.arc
do
    arccopy=$(basename "$arc")
    
    echo "Copying $arccopy"
    cp "$arc" .
    
    echo "Unarchiving $arccopy"
    "$1" -ddo -pc -tex -v 7 "$arccopy"

    icon=`find "${arccopy%.*}" -type f -name "*.dds"`
    iconbasename=`basename "$icon"`
    echo "Converting item icon $iconbasename to png"
    magick convert "$icon" "../icons/${iconbasename%.*}.png"

    # Clean up arc file
    rm "$arccopy"
done

# Copy map files and unpack them
for arc in "$2"/nativePC/rom/ui/02_map/map/**/*.arc
do
    arccopy=$(basename "$arc")
    
    echo "Copying $arccopy"
    cp "$arc" .
    
    echo "Unarchiving $arccopy"
    "$1" -ddo -pc -tex -v 7 "$arccopy"

    # Clean up arc file
    rm "$arccopy"
done

# Stitch together unpacked maps
cd ..
zx --experimental mapstitcher.mjs

# Clean up
rm -r tmp

# Optimize pngs
cd results
oxipng ./*