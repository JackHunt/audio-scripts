#!/bin/bash

function maybe_backup() {
  file="$1"

  if [[ -f $file ]]; then
    file_bak="$file.bak"
    if [[ -f $file_bak ]]; then
      echo "\t-> Removing old backup: $file_bak"
      rm $file_bak
    fi

    echo "\t-> Backing up $file to $file_bak"
    cp $file $file_bak
  else
    echo "\t-> ERROR: File not found: $file"
  fi
}

function update_library() {
  file="$1"
  target="$2"

  maybe_backup $file

  MAC_PATH="/:Users/:jackhunt/:Library/:Mobile Documents/:com~apple~CloudDocs"
  MAC_VOL="VOLUME=\"Macintosh HD\""
  MAC_VOL_ID="VOLUMEID=\"Macintosh HD\""

  WIN_PATH="/:Sync/:iCloudDrive"
  WIN_VOL="VOLUME=\"D:\""
  WIN_VOL_ID="VOLUMEID=\"6c458104\""

  if [[ $target == "win" ]]; then
    from_path=$MAC_PATH
    to_path=$WIN_PATH

    from_vol=$MAC_VOL
    to_vol=$WIN_VOL

    from_vol_id=$MAC_VOL_ID
    to_vol_id=$WIN_VOL_ID
  elif [[ $target == "mac" ]]; then
    from_path=$WIN_PATH
    to_path=$MAC_PATH

    from_vol=$WIN_VOL
    to_vol=$MAC_VOL

    from_vol_id=$WIN_VOL_ID
    to_vol_id=$MAC_VOL_ID
  else
    echo "Unknown target: $target"
    exit 1
  fi

  sed -i '' "s|$from_path|$to_path|g" "$file"
  sed -i '' "s|$from_vol|$to_vol|g" "$file"
  sed -i '' "s|$from_vol_id|$to_vol_id|g" "$file"
}

function update_settings() {
  file="$1"
  target="$2"

  maybe_backup $file

  MAC_PATH_1="Macintosh HD:Users:jackhunt:Documents:Native Instruments:"
  MAC_PATH_2="Macintosh HD:Users:jackhunt:Library:Mobile Documents:com~apple~CloudDocs:"

  if [[ $target == "win" ]]; then
    ""
  elif [[ $target == "mac" ]]; then
    ""
  else
    echo "Unknown target: $target"
    exit 1
  fi
}

if [[ "$1" == "--to-windows" ]]; then
  target="win"
elif [[ $1 == "--to-mac" ]]; then
  target="mac"
else
  echo "Usage: $0 [--to-windows|--to-mac]"
  exit 1
fi

update_library "test/collection.nml" $target

update_settings "test/Traktor Settings.tsi" $target
