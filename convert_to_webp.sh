#!/usr/bin/env bash

# Function to recursively process directories
process_directory() {
  local input_dir="$1"
  local output_dir="$2"

  # Loop through all files and directories in the given directory
  for item in "$input_dir"/*; do
    if [ -d "$item" ]; then
      # If the item is a directory, create the corresponding output directory and process recursively
      local sub_dir="$output_dir/$(basename "$item")"
      mkdir -p "$sub_dir"
      process_directory "$item" "$sub_dir"
    elif [ -f "$item" ]; then
      # If the item is a file, process it
      convert_to_webp "$item" "$output_dir"
    fi
  done
}

# Function to convert an image file to WebP format
convert_to_webp() {
  local input_file="$1"
  local output_dir="$2"

  # Supported file extensions
  local supported_extensions="png jpg jpeg bmp tiff"
  local extension="${input_file##*.}"

  # Check if the file has a supported extension
  if [[ ! " $supported_extensions " =~ " ${extension,,} " ]]; then
    return
  fi

  # Generate the output WebP file path
  local output_file="$output_dir/$(basename "${input_file%.*}.webp")"

  # Skip conversion if the WebP file already exists
  if [ -f "$output_file" ]; then
    echo "⚠️  Skipping: '$output_file' already exists."
    return
  fi

  # Convert the file to WebP using cwebp
  cwebp -quiet -q 90 "$input_file" -o "$output_file"
  if [ $? -eq 0 ]; then
    echo "✅ Converted: '$input_file' → '$output_file'"
  else
    echo "❌ Failed to convert: '$input_file'"
  fi
}

# Main script execution
main() {
  if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <input_directory> <output_directory>"
    exit 1
  fi

  local input_directory="$1"
  local output_directory="$2"

  # Check if the input is a valid directory
  if [ ! -d "$input_directory" ]; then
    echo "Error: '$input_directory' is not a valid directory."
    exit 1
  fi

  # Create the output directory if it doesn't exist
  mkdir -p "$output_directory"

  # Start processing the directory
  process_directory "$input_directory" "$output_directory"
}

# Start the script
main "$@"
