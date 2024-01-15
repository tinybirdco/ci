#!/usr/bin/env bash

fail=0;

directory="datasources/fixtures"
extensions=("csv" "ndjson")

# Get the absolute path of the directory
absolute_directory=$(realpath "$directory")

for extension in "${extensions[@]}"; do
  # Use find command to get the list of file names
  file_list=$(find "$absolute_directory" -type f -name "*.$extension")

  for file_path in $file_list; do
    file_name=$(basename "$file_path")
    file_name_without_extension="${file_name%.*}"

    command="tb datasource append $file_name_without_extension datasources/fixtures/$file_name"
    echo $command
    $command
  done
done
