#!/bin/bash
set -euo pipefail
IFS=$'\n\t'
# Bash strict mode

if [[ $# -lt 2 ]]
then 
    echo "Usage: ./mapextractor.sh \"/path/to/ARCtool\" \"/path/to/Dragon's Dogma Online\""
fi

cd "$(dirname "$0")"

mkdir results
mkdir tmp
cd tmp

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

# Stitch images together
for image in $(find ./ -type d -regex "\.\/[a-z]+[0-9]+_m[0-9]+")
do
    echo "Stitching $image"
    imagefile=$(basename "$image")
    magick montage $(find . -type f -wholename ""$image"**/*.dds") -geometry +0+0 -tile $(find . -type f -wholename ""$image"_00*_0000/**/*.dds" | wc -l)x "../results/$imagefile.png"
done

# Clean up
cd ..
rm -r tmp