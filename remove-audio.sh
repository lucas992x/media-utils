#!/bin/bash

# This script removes audio track from a video without conversion. Arguments:
# -i: input file.
# -o: output file (optional).
# -d: to set a different output directory (useful if processing multiple files
# at once; ignored if -o is passed).
# -e: to use same input file name but different extension (if compatible).
# If neither -o, -d or -e is passed, output file name is same as input with
# " no audio" appended before file extension.

# read arguments
while getopts ":i:o:d:e:" arg; do
    case $arg in
    i)
        input="$OPTARG"
        ;;
    o)
        output="$OPTARG"
        ;;
    d)
        dest_dir="$OPTARG"
        ;;
    e)
        ext="$OPTARG"
        ;;
    esac
done

# set output file if not specified
if [[ -z "$output" ]]; then
    # automatically set output file name
    input_ext="${input##*.}"
    if [[ -z "$ext" ]]; then
        output="${input/.$input_ext/" no audio.$input_ext"}"
    else
        output="${input/$input_ext/$ext}"
    fi
    # check if output directory was specified
    if [[ ! -z "$dest_dir" ]]; then
        output="$dest_dir/$(basename "$output")"
    fi
fi
# execute command
ffmpeg -hide_banner -i "$input" -vcodec copy -an "$output"
