#!/bin/bash

if ! command -v ffmpeg &> /dev/null; then
  echo "Error: ffmpeg is not installed. Install it with 'brew install ffmpeg'."
  exit 1
fi

if [ -z "$1" ]; then
  echo "Usage: $0 /path/to/your/directory [-m] [-o]"
  exit 1
fi

TOP_DIR="$1"
CONVERT_TO_MONO=false
OVERWRITE_ORIGINAL=false

# Process the options
shift
while getopts "mo" opt; do
  case $opt in
    m)
      CONVERT_TO_MONO=true
      ;;
    o)
      OVERWRITE_ORIGINAL=true
      ;;
    *)
      echo "Usage: $0 /path/to/your/directory [-m] [-o]"
      exit 1
      ;;
  esac
done

process_directory() {
  INPUT_DIR="$1"
  OUTPUT_DIR="$INPUT_DIR/converted"

  if [ "$OVERWRITE_ORIGINAL" = false ]; then
    mkdir -p "$OUTPUT_DIR"
  fi

  for file in "$INPUT_DIR"/*; do
    if [ ! -f "$file" ]; then
      continue
    fi

    extension="${file##*.}"
    basename=$(basename "$file" ."$extension")

    if [[ "$extension" != "wav" && "$extension" != "WAV" ]]; then
      echo "Skipping non-wav file: $file"
      continue
    fi

    if [ "$OVERWRITE_ORIGINAL" = true ]; then
      temp_file="$(mktemp).wav"
      echo "Converting (temporary): $file -> $temp_file"
      if [ "$CONVERT_TO_MONO" = true ]; then
        ffmpeg -i "$file" -ar 44100 -ac 1 -sample_fmt s16 "$temp_file"
      else
        ffmpeg -i "$file" -ar 44100 -ac 2 -sample_fmt s16 "$temp_file"
      fi
      mv "$temp_file" "$file"
      echo "Overwritten: $file"
    else
      output_file="$OUTPUT_DIR/$basename.wav"
      echo "Converting: $file -> $output_file"
      if [ "$CONVERT_TO_MONO" = true ]; then
        ffmpeg -i "$file" -ar 44100 -ac 1 -sample_fmt s16 "$output_file"
      else
        ffmpeg -i "$file" -ar 44100 -ac 2 -sample_fmt s16 "$output_file"
      fi
    fi
  done
}

find "$TOP_DIR" -type d | while read -r SUB_DIR; do
  echo "Processing directory: $SUB_DIR"
  process_directory "$SUB_DIR"
done

echo "All conversions completed."