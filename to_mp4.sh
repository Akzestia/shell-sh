#!/bin/bash

command -v ffmpeg >/dev/null 2>&1 || { echo >&2 "ffmpeg is required; please install it."; exit 1; }

input_file="$1"

if [ ! -f "$input_file" ]; then
  echo "Error: Input file '$input_file' not found."
  exit 1
fi

base_name=$(basename "$input_file")
extension="${input_file##*.}"

output_file="${base_name}.mp4"

ffmpeg -i "$input_file" -c:v libx264 -c:a aac "$output_file"

if [ $? -eq 0 ]; then
  echo "Converted '$input_file' to '$output_file'"
else
  echo "Error converting '$input_file' to '$output_file'"
fi
