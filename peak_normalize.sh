#!/bin/bash

if ! command -v ffmpeg &> /dev/null; then
  echo "Error: ffmpeg is not installed. Install it with 'brew install ffmpeg'."
  exit 1
fi

if [ -z "$1" ]; then
  echo "Usage: $0 /path/to/your/directory [-o]"
  exit 1
fi

TOP_DIR="$1"
OVERWRITE_ORIGINAL=false

# Process options
shift
while getopts "o" opt; do
  case $opt in
    o)
      OVERWRITE_ORIGINAL=true
      ;;
    *)
      echo "Usage: $0 /path/to/your/directory [-o]"
      exit 1
      ;;
  esac
done

function process_directory() {
  INPUT_DIR="$1"
  OUTPUT_DIR="$INPUT_DIR/normalized"

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

    peak_db=$(ffmpeg -i "$file" -af volumedetect -f null /dev/null 2>&1 | \
              grep 'max_volume:' | awk '{print $5}' | sed 's/dB//')

    if [ -z "$peak_db" ]; then
      echo "Could not detect peak for $file. Skipping."
      continue
    fi

    gain=$(echo "0 - $peak_db" | bc)

    if [ "$OVERWRITE_ORIGINAL" = true ]; then
      temp_file="$(mktemp).wav"
      echo "Normalizing (temporary): $file -> $temp_file (gain: ${gain}dB)"
      ffmpeg -i "$file" -af "volume=${gain}dB" -y "$temp_file"
      mv "$temp_file" "$file"
      echo "Overwritten: $file"
    else
      output_file="$OUTPUT_DIR/$basename.wav"
      echo "Normalizing: $file -> $output_file (gain: ${gain}dB)"
      ffmpeg -i "$file" -af "volume=${gain}dB" -y "$output_file"
    fi
  done
}

find "$TOP_DIR" -type d | while read -r SUB_DIR; do
  echo "Processing directory: $SUB_DIR"
  process_directory "$SUB_DIR"
done

echo "All normalizations completed."
