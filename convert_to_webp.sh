#!/usr/bin/env bash

set -euo pipefail  # Exit on error, undefined vars, and pipe failures

# Configuration
readonly DEFAULT_QUALITY=90
readonly DEFAULT_THREADS=$(nproc 2>/dev/null || echo "4")
readonly SUPPORTED_EXTENSIONS=("png" "jpg" "jpeg" "bmp" "tiff" "gif" "tga" "webp")
readonly LOG_FILE="webp_conversion.log"

# Global counters
declare -g converted_count=0
declare -g skipped_count=0
declare -g failed_count=0
declare -g start_time

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Logging function
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    
    case "$level" in
        "ERROR") echo -e "${RED}❌ $message${NC}" ;;
        "SUCCESS") echo -e "${GREEN}✅ $message${NC}" ;;
        "WARNING") echo -e "${YELLOW}⚠️  $message${NC}" ;;
        "INFO") echo -e "${BLUE}ℹ️  $message${NC}" ;;
        *) echo "$message" ;;
    esac
}

# Show help
show_help() {
    cat << EOF
Usage: $0 [OPTIONS] <input_directory> <output_directory>

Convert images to WebP format recursively.

OPTIONS:
    -q, --quality QUALITY    Quality level (0-100, default: $DEFAULT_QUALITY)
    -t, --threads THREADS    Number of parallel processes (default: $DEFAULT_THREADS)
    -f, --force             Overwrite existing WebP files
    -v, --verbose           Verbose output
    -h, --help              Show this help message
    --lossless              Use lossless compression
    --preserve-metadata     Preserve image metadata
    --dry-run               Show what would be converted without doing it

EXAMPLES:
    $0 ./images ./webp_output
    $0 -q 80 -t 8 ./photos ./compressed
    $0 --lossless --preserve-metadata ./originals ./webp
    $0 --dry-run ./test ./output

SUPPORTED FORMATS: ${SUPPORTED_EXTENSIONS[*]}
EOF
}

# Parse command line arguments
parse_args() {
    local quality="$DEFAULT_QUALITY"
    local threads="$DEFAULT_THREADS"
    local force=false
    local verbose=false
    local lossless=false
    local preserve_metadata=false
    local dry_run=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -q|--quality)
                quality="$2"
                if ! [[ "$quality" =~ ^[0-9]+$ ]] || [ "$quality" -lt 0 ] || [ "$quality" -gt 100 ]; then
                    log "ERROR" "Quality must be a number between 0 and 100"
                    exit 1
                fi
                shift 2
                ;;
            -t|--threads)
                threads="$2"
                if ! [[ "$threads" =~ ^[0-9]+$ ]] || [ "$threads" -lt 1 ]; then
                    log "ERROR" "Threads must be a positive number"
                    exit 1
                fi
                shift 2
                ;;
            -f|--force)
                force=true
                shift
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            --lossless)
                lossless=true
                shift
                ;;
            --preserve-metadata)
                preserve_metadata=true
                shift
                ;;
            --dry-run)
                dry_run=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            -*)
                log "ERROR" "Unknown option: $1"
                show_help
                exit 1
                ;;
            *)
                break
                ;;
        esac
    done
    
    # Export variables for use in other functions
    export QUALITY="$quality"
    export THREADS="$threads"
    export FORCE="$force"
    export VERBOSE="$verbose"
    export LOSSLESS="$lossless"
    export PRESERVE_METADATA="$preserve_metadata"
    export DRY_RUN="$dry_run"
    
    # Remaining arguments should be input and output directories
    if [ $# -ne 2 ]; then
        log "ERROR" "Input and output directories are required"
        show_help
        exit 1
    fi
    
    export INPUT_DIR="$1"
    export OUTPUT_DIR="$2"
}

# Check if required tools are available
check_dependencies() {
    local missing_tools=()
    
    if ! command -v cwebp &> /dev/null; then
        missing_tools+=("cwebp")
    fi
    
    if ! command -v identify &> /dev/null; then
        missing_tools+=("imagemagick (identify command)")
    fi
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        log "ERROR" "Missing required tools: ${missing_tools[*]}"
        log "INFO" "Install with: sudo apt-get install webp imagemagick"
        exit 1
    fi
}

# Check if file is a supported image format
is_supported_format() {
    local file="$1"
    local extension="${file##*.}"
    extension="${extension,,}"  # Convert to lowercase
    
    for ext in "${SUPPORTED_EXTENSIONS[@]}"; do
        if [[ "$extension" == "$ext" ]]; then
            return 0
        fi
    done
    return 1
}

# Get image dimensions and file size
get_image_info() {
    local file="$1"
    local info
    
    if info=$(identify -format "%wx%h %b" "$file" 2>/dev/null); then
        echo "$info"
    else
        echo "unknown unknown"
    fi
}

# Convert single file to WebP
convert_to_webp() {
    local input_file="$1"
    local output_dir="$2"
    
    # Check if it's a supported format
    if ! is_supported_format "$input_file"; then
        [[ "$VERBOSE" == "true" ]] && log "INFO" "Skipping unsupported format: '$(basename "$input_file")'"
        return 0
    fi
    
    # Generate output file path
    local basename="${input_file##*/}"
    local filename="${basename%.*}"
    local output_file="$output_dir/${filename}.webp"
    
    # Skip if file already exists and force is not enabled
    if [[ -f "$output_file" && "$FORCE" != "true" ]]; then
        log "WARNING" "Skipping: '$(basename "$output_file")' already exists"
        ((skipped_count++))
        return 0
    fi
    
    # Get original file info
    local original_info
    original_info=$(get_image_info "$input_file")
    local original_size=$(echo "$original_info" | cut -d' ' -f2)
    
    # Dry run mode
    if [[ "$DRY_RUN" == "true" ]]; then
        log "INFO" "Would convert: '$input_file' → '$output_file'"
        return 0
    fi
    
    # Build cwebp command
    local cwebp_cmd="cwebp"
    
    if [[ "$LOSSLESS" == "true" ]]; then
        cwebp_cmd+=" -lossless"
    else
        cwebp_cmd+=" -q $QUALITY"
    fi
    
    if [[ "$PRESERVE_METADATA" == "true" ]]; then
        cwebp_cmd+=" -metadata all"
    fi
    
    if [[ "$VERBOSE" != "true" ]]; then
        cwebp_cmd+=" -quiet"
    fi
    
    cwebp_cmd+=" \"$input_file\" -o \"$output_file\""
    
    # Execute conversion
    if eval "$cwebp_cmd"; then
        local new_size
        new_size=$(stat -f%z "$output_file" 2>/dev/null || stat -c%s "$output_file" 2>/dev/null || echo "unknown")
        
        if [[ "$new_size" != "unknown" && "$original_size" != "unknown" ]]; then
            local savings
            savings=$(echo "scale=1; (1 - $new_size / ${original_size//[^0-9]/}) * 100" | bc 2>/dev/null || echo "0")
            log "SUCCESS" "Converted: '$(basename "$input_file")' → '$(basename "$output_file")' (${savings}% smaller)"
        else
            log "SUCCESS" "Converted: '$(basename "$input_file")' → '$(basename "$output_file")'"
        fi
        ((converted_count++))
    else
        log "ERROR" "Failed to convert: '$input_file'"
        ((failed_count++))
        return 1
    fi
}

# Process directory recursively
process_directory() {
    local input_dir="$1"
    local output_dir="$2"
    
    # Create output directory
    mkdir -p "$output_dir"
    
    # Process files in parallel
    local pids=()
    local active_jobs=0
    
    # Process all items in directory
    while IFS= read -r -d '' item; do
        if [[ -d "$item" ]]; then
            # Handle subdirectory
            local sub_dir="$output_dir/$(basename "$item")"
            process_directory "$item" "$sub_dir"
        elif [[ -f "$item" ]]; then
            # Handle file - use parallel processing
            if [[ $active_jobs -ge $THREADS ]]; then
                # Wait for any job to complete
                wait -n
                ((active_jobs--))
            fi
            
            # Start conversion in background
            convert_to_webp "$item" "$output_dir" &
            pids+=($!)
            ((active_jobs++))
        fi
    done < <(find "$input_dir" -maxdepth 1 -print0 2>/dev/null)
    
    # Wait for all remaining jobs
    for pid in "${pids[@]}"; do
        wait "$pid"
    done
}

# Show progress summary
show_summary() {
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    local total_files=$((converted_count + skipped_count + failed_count))
    
    echo
    log "INFO" "=== Conversion Summary ==="
    log "INFO" "Total files processed: $total_files"
    log "INFO" "Successfully converted: $converted_count"
    log "INFO" "Skipped: $skipped_count"
    log "INFO" "Failed: $failed_count"
    log "INFO" "Time elapsed: ${duration}s"
    log "INFO" "Log file: $LOG_FILE"
    echo
    
    if [[ $failed_count -gt 0 ]]; then
        exit 1
    fi
}

# Cleanup function for signal handling
cleanup() {
    log "WARNING" "Script interrupted. Cleaning up..."
    # Kill any background jobs
    jobs -p | xargs -r kill 2>/dev/null
    show_summary
    exit 130
}

# Main function
main() {
    start_time=$(date +%s)
    
    # Set up signal handlers
    trap cleanup SIGINT SIGTERM
    
    # Parse arguments
    parse_args "$@"
    
    # Check dependencies
    check_dependencies
    
    # Validate input directory
    if [[ ! -d "$INPUT_DIR" ]]; then
        log "ERROR" "'$INPUT_DIR' is not a valid directory"
        exit 1
    fi
    
    # Initialize log file
    echo "=== WebP Conversion Log - $(date) ===" > "$LOG_FILE"
    
    log "INFO" "Starting conversion..."
    log "INFO" "Input directory: $INPUT_DIR"
    log "INFO" "Output directory: $OUTPUT_DIR"
    log "INFO" "Quality: $QUALITY"
    log "INFO" "Threads: $THREADS"
    log "INFO" "Lossless: $LOSSLESS"
    log "INFO" "Force overwrite: $FORCE"
    
    # Start processing
    process_directory "$INPUT_DIR" "$OUTPUT_DIR"
    
    # Show summary
    show_summary
}

# Run main function with all arguments
main "$@"
