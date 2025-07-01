# Convert to WebP Pro 🚀

A powerful, enterprise-grade Bash script that recursively converts images to WebP format with advanced features like parallel processing, comprehensive logging, and flexible configuration options. This tool leverages WebP's superior compression technology to achieve up to 90% file size reduction while maintaining exceptional visual quality.

## ✨ Features

### Core Functionality
* **Recursive batch processing** with directory structure preservation
* **Parallel conversion** using multi-threading for optimal performance
* **Smart file detection** with comprehensive format support
* **Intelligent skip logic** to avoid duplicate conversions
* **Real-time progress tracking** with colorized output and emojis

### Advanced Options
* **Flexible quality control** (0-100 scale or lossless mode)
* **Metadata preservation** for professional workflows
* **Force overwrite mode** for updating existing files
* **Dry-run capability** for safe testing
* **Comprehensive logging** with detailed conversion reports
* **Space savings calculation** with compression statistics

### Supported Formats
* PNG, JPG/JPEG, BMP, TIFF, GIF, TGA, WebP

## 🛠️ Requirements

* **Bash** (version 4.0 or higher)
* **cwebp** converter tool (WebP encoder)
* **ImageMagick** (for image analysis and metadata)

### Installing Dependencies

Choose your operating system and run the corresponding commands:

#### macOS (using Homebrew)
```bash
brew install webp imagemagick
```

#### Ubuntu/Debian
```bash
sudo apt update
sudo apt install webp imagemagick
```

#### CentOS/RHEL/Fedora
```bash
# CentOS/RHEL 7-8
sudo yum install libwebp-tools ImageMagick

# CentOS/RHEL 9+ and Fedora
sudo dnf install libwebp-tools ImageMagick
```

#### Alpine Linux
```bash
apk add libwebp-tools imagemagick
```

#### Arch Linux
```bash
pacman -S libwebp imagemagick
```

#### Windows (using WSL)
```bash
sudo apt install webp imagemagick
```

## 🚀 Quick Start

1. **Make the script executable:**
```bash
chmod +x convert_to_webp.sh
```

2. **Basic usage:**
```bash
./convert_to_webp.sh <input_directory> <output_directory>
```

3. **Example:**
```bash
./convert_to_webp.sh ~/Photos/originals ~/Photos/webp_optimized
```

## 📖 Advanced Usage

### Command Line Options

```bash
./convert_to_webp.sh [OPTIONS] <input_directory> <output_directory>
```

| Option | Description | Default |
|--------|-------------|---------|
| `-q, --quality QUALITY` | Quality level (0-100) | 90 |
| `-t, --threads THREADS` | Number of parallel processes | CPU cores |
| `-f, --force` | Overwrite existing WebP files | false |
| `-v, --verbose` | Enable verbose output | false |
| `--lossless` | Use lossless compression | false |
| `--preserve-metadata` | Preserve image metadata | false |
| `--dry-run` | Preview without converting | false |
| `-h, --help` | Show help message | - |

### Usage Examples

#### Basic Conversion
```bash
# Convert with default settings (quality 90, auto-detect CPU cores)
./convert_to_webp.sh ./images ./webp_output
```

#### High-Performance Batch Processing
```bash
# Use 8 threads with 80% quality for faster processing
./convert_to_webp.sh -q 80 -t 8 ./photos ./compressed
```

#### Lossless Conversion for Professional Work
```bash
# Lossless conversion with metadata preservation
./convert_to_webp.sh --lossless --preserve-metadata ./originals ./webp_masters
```

#### Force Update Existing Files
```bash
# Overwrite existing WebP files with new settings
./convert_to_webp.sh -f -q 95 ./source ./destination
```

#### Safe Testing Mode
```bash
# Preview what would be converted without actually doing it
./convert_to_webp.sh --dry-run ./test_images ./preview_output
```

#### Verbose Monitoring
```bash
# Detailed output for monitoring large batch jobs
./convert_to_webp.sh -v -t 12 ./massive_collection ./webp_collection
```

## 📊 Output and Logging

### Console Output
The script provides real-time feedback with:
- ✅ **Success indicators** with file size savings
- ⚠️ **Skip notifications** for existing files
- ❌ **Error reports** for failed conversions
- ℹ️ **Progress information** and statistics

### Conversion Log
A detailed log file (`webp_conversion.log`) is automatically created containing:
- Timestamp for each operation
- Detailed conversion statistics
- Error diagnostics and troubleshooting information
- Performance metrics and space savings

### Summary Report
After completion, you'll receive:
```
=== Conversion Summary ===
Total files processed: 1,247
Successfully converted: 1,198
Skipped: 45
Failed: 4
Time elapsed: 127s
Log file: webp_conversion.log
```

## 🎯 Performance Optimization

### Recommended Settings by Use Case

#### Web Optimization (Maximum Compression)
```bash
./convert_to_webp.sh -q 75 -t 8 ./web_assets ./optimized_web
```

#### Photography (Balanced Quality/Size)
```bash
./convert_to_webp.sh -q 90 --preserve-metadata ./photos ./webp_photos
```

#### Archival (Maximum Quality)
```bash
./convert_to_webp.sh --lossless --preserve-metadata ./archives ./webp_archives
```

## 🔧 Troubleshooting

### Common Issues

**Permission Denied:**
```bash
chmod +x convert_to_webp.sh
```

**Command Not Found (cwebp):**
- Ensure WebP tools are installed (see installation section)
- Check PATH configuration: `which cwebp`

**Out of Memory:**
- Reduce thread count: `-t 2`
- Process smaller batches
- Check available system memory

**Slow Performance:**
- Increase thread count: `-t 16`
- Use lower quality settings: `-q 75`
- Ensure sufficient disk I/O bandwidth

### Getting Help

```bash
# Show complete help and examples
./convert_to_webp.sh --help

# Check tool availability
which cwebp identify

# Test with a single file first
./convert_to_webp.sh --dry-run single_image_folder test_output
```

## 📈 Benefits of WebP

- **Superior Compression:** Up to 35% smaller than JPEG, 50% smaller than PNG
- **Modern Browser Support:** Supported by all major browsers (Chrome, Firefox, Safari, Edge)
- **Quality Preservation:** Maintains visual quality while reducing file size
- **Transparency Support:** Full alpha channel support like PNG
- **Animation Support:** Can replace GIFs with better compression

## 🤝 Contributing

This script is designed to be robust and user-friendly. If you encounter issues or have suggestions for improvements, please feel free to:

1. Test thoroughly with your specific use cases
2. Report bugs with detailed reproduction steps
3. Suggest new features that would benefit the community
4. Share performance optimization discoveries

## 📄 License

This script is provided as-is for educational and practical use. Feel free to modify and distribute according to your needs.

---

**Made with ❤️ for efficient image optimization**
