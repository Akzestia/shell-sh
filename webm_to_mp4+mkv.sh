#!/bin/bash

print_usage() {
    echo "Usage: $0 [-i input_file] [-f format] [-o output_file]"
    echo "Options:"
    echo "  -i    Input WebM file"
    echo "  -f    Output format (mkv or mp4)"
    echo "  -o    Output filename (optional)"
    echo ""
    echo "Example:"
    echo "  $0 -i video.webm -f mp4"
    echo "  $0 -i video.webm -f mkv -o custom_name.mkv"
}

if ! command -v ffmpeg &> /dev/null; then
    echo "Error: ffmpeg is not installed. Please install it first."
    exit 1
fi

while getopts "i:f:o:h" opt; do
    case $opt in
        i) input_file="$OPTARG";;
        f) format="$OPTARG";;
        o) output_file="$OPTARG";;
        h) print_usage; exit 0;;
        ?) print_usage; exit 1;;
    esac
done

if [ -z "$input_file" ]; then
    echo "Error: Input file is required"
    print_usage
    exit 1
fi

if [ ! -f "$input_file" ]; then
    echo "Error: Input file '$input_file' does not exist"
    exit 1
fi

if [ -z "$format" ]; then
    echo "Error: Output format is required"
    print_usage
    exit 1
fi

if [ "$format" != "mkv" ] && [ "$format" != "mp4" ]; then
    echo "Error: Invalid format. Use 'mkv' or 'mp4'"
    exit 1
fi

if [ -z "$output_file" ]; then
    output_file="${input_file%.*}.$format"
fi

echo "Converting '$input_file' to $format format..."
ffmpeg -i "$input_file" -c:v copy -c:a copy "$output_file"

if [ $? -eq 0 ]; then
    echo "Conversion completed successfully!"
    echo "Output saved as: $output_file"
else
    echo "Error: Conversion failed"
    exit 1
fi
