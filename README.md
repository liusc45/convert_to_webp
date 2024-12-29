# Convert to WebP

A powerful and efficient Bash script that recursively converts images to WebP format while preserving directory structures. This tool optimizes your images using WebP's superior compression technology, achieving significant file size reductions without compromising quality.

## Features

* Recursive directory scanning for batch processing
* Preserves original folder structure and hierarchy
* Comprehensive format support:
  * PNG
  * JPG/JPEG
  * BMP
  * TIFF
* Quality-preserving conversion
* Real-time progress tracking
* Robust error handling and reporting
* Maintains image metadata

## Requirements

* **Bash** (version 4.0 or higher)
* **cwebp** converter tool

### Installing cwebp

Choose your operating system and run the corresponding command:

```bash
# macOS (using Homebrew)
brew install webp

# Ubuntu/Debian
sudo apt install webp

# CentOS/RHEL
sudo yum install libwebp-tools

# Alpine Linux
apk add libwebp-tools

# Arch Linux
pacman -S libwebp
```

## Usage

1. First, make the script executable:
```bash
chmod +x convert_to_webp.sh
```

2. Run the script with input and output directories:
```bash
./convert_to_webp.sh <input_directory> <output_directory>
```

### Example

```bash
# Convert images from Desktop/uploads to Desktop/optimized
./convert_to_webp.sh ~/Desktop/uploads ~/Desktop/optimized
```