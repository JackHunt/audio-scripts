#!/bin/bash

FILES=(
  "test/collection.nml"
)

MAC_PATH="/:Users/:jackhunt/:Library/:Mobile Documents/:com~apple~CloudDocs"
WIN_PATH="/:User/:jackhunt/:iCloud"

if [[ "$1" == "--to-windows" ]]; then
  from_path=$MAC_PATH
  to_path=$WIN_PATH
elif [[ $1 == "--to-mac" ]]; then
  from_path=$WIN_PATH
  to_path=$MAC_PATH
else
  echo "Usage: $0 [--to-windows|--to-mac]"
  exit 1
fi

for file in "${FILES[@]}"; do
  echo "PROCESSING: $file"
  if [[ -f $file ]]; then
    file_bak="$file.bak"
    if [[ -f $file_bak ]]; then
      echo "\t-> Removing old backup: $file_bak"
      rm $file_bak
    fi

    echo "\t-> Backing up $file to $file_bak"
    cp $file $file_bak

    echo "\t-> Updating $file..."
    sed -i '' "s|$from_path|$to_path|g" "$file"
  else
    echo "\t-> ERROR: File not found: $file"
  fi
done
