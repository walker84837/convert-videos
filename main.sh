#!/usr/bin/env bash

# TODO: put this behind getopt + help menu
for file in $(ls *.mp4); do
    # file-fhd
    file_stripped="${file%%.*}"
    file_raw="${}"
    new_video="$file_stripped-fhd.mp4"
    # TODO: file check incorrect (result ex. file-fhd-fhd.mp4 never exists)
    if [ ! -f "$new_video" ]; then
        ffmpeg -i "$file" -vf scale=1920:1080 "$new_video" -y
    fi
done