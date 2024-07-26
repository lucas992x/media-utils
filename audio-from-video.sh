#!/bin/bash

# This script extracts audio track from a video without conversion. Arguments:
# -i: input file.
# -a: audio track index (optional, only useful when video contains multiple
# audio tracks): remember that first track is number 0, second is 1, and so on.
# -o: output file (optional, if missing uses same name as input).
# -d: to set a different output directory (useful if processing multiple files
# at once; ignored if -o is passed).
# -m: only show file metadata, without performing actions.
# If a video with multiple audio tracks is passed without -a, only the first
# audio track is extracted from it.

# read arguments
while getopts ":i:o:d:a:m" arg; do
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
    a)
        audio_track="$OPTARG"
        ;;
    m)
        ffmpeg -hide_banner -i "$input"
        exit 1
        ;;
    esac
done

# set output file if not specified
if [[ -z "$output" ]]; then
    # automatically detect extension of audio track
    search_string=".*\bAudio: (\w+)\b.*"
    match=$(ffprobe -hide_banner "$input" 2>&1 | grep -iE "$search_string")
    # check if multiple audio tracks were found
    check_multi_audio=$(echo "$match" | grep -iE '\n')
    if [[ ! -z "$check_multi_audio" && -z $audio_track ]]; then
        echo "File '$input' contains multiple audio tracks, only the first one will be extracted; if you want to extract a different track specify it using -a"
        match="${match%%$'\n'*}"
    fi
    # get extension and set output file name
    audio_ext="$(echo "$match" | sed -E "s/$search_string/\1/g")"
    video_ext="${input##*.}"
    output="${input/$video_ext/$audio_ext}"
    if [[ ! -z "$dest_dir" ]]; then
        output="$dest_dir/$(basename "$output")"
    fi
fi
# build command
command="ffmpeg -hide_banner -i '$input' -vn -acodec copy"
if [[ ! -z $audio_track ]]; then
    command+=" -map 0:a:$audio_track"
fi
command+=" '$output'"
#echo "$command"
eval $command
