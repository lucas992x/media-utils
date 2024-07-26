#!/bin/bash

# set help message
help="This script arranges many images in a grid and saves result in output image.
Arguments:
-i: input, can be a folder or a list of images separated by delimiter.
-d: delimiter (only needed if passing a list of images, default semicolon).
-g: size of grid, can be '4x' to have 4 columns, 'x6' to have 6 rows, '4x6' to
have 4 columns and 6 rows (in this case output may consist of multiple images).
-m: margin of each image (actual space between images will be two times this
value, default is 0).
-b: background color if using margin (default transparent).
-o: output image(s)."
# set default values if args are not passed
delimiter=";"
margin="0"
bg="none"
# read args
while getopts "hi:d:g:m:b:o:" arg; do
    case $arg in
    h)
        echo "$help"
        exit 0
        ;;
    i)
        input="$OPTARG"
        ;;
    d)
        delimiter="$OPTARG"
        ;;
    g)
        grid="$OPTARG"
        ;;
    m)
        margin="$OPTARG"
        ;;
    b)
        bg="$OPTARG"
        ;;
    o)
        output="$OPTARG"
        ;;
    *)
        exit 1
        ;;
    esac
done
# build command
command="montage"
# add input images
if [[ -d "$input" ]]; then
    for item in "$input"/*; do
        if [[ -f "$item" ]]; then
            command+=" '$item'"
        fi
    done
else
    readarray -d "$delimiter" -t items < <(printf '%s' "$input")
    for ((j = 0; j < ${#items[*]}; j++)); do
        command+=" '${items[j]}'"
    done
fi
# set grid size
command+=" -tile '$grid'"
# set margin and background
command+=" -geometry '+$margin+$margin' -background '$bg'"
if [[ "$margin" -gt 0 ]]; then
    command+=" miff:- | convert - "
    if [[ "$bg" == "none" ]]; then
        command+=" -matte"
    fi
    command+=" -bordercolor '$bg' -border '$margin'"
fi
# add output
command+=" '$output'"
#echo "$command"
eval $command
echo "Generated grid \"$output\""
