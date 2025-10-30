#!/bin/bash

# --- 1. CONFIGURATION ---
INPUT_FILE="allurls.txt"
JS_URLS_FILE="js_urls.txt"
UNIQUE_JS_URLS_FILE="unique_js_urls.txt"
DOWNLOAD_DIR="js_source_code"
PARALLEL_JOBS=10  # Number of parallel downloads (adjust based on your system/network)
TIMEOUT_SECONDS=7 # Timeout for each download attempt

# --- 2. URL EXTRACTION (grep) ---
echo "=================================================="
echo "⚡ Starting Step 1: Extracting .js URLs from $INPUT_FILE..."
echo "=================================================="

# Check if the input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "ERROR: Input file '$INPUT_FILE' not found. Exiting."
    exit 1
fi

# Use grep to find all lines ending with .js, .js? or .js#
# -i: Ignore case
# -E: Extended regular expressions
grep -iE '\.js(\?|\#|$)' "$INPUT_FILE" > "$JS_URLS_FILE"

LINE_COUNT=$(wc -l < "$JS_URLS_FILE" | tr -d '[:space:]')

echo "✅ Extraction complete. Found $LINE_COUNT JavaScript URLs in $JS_URLS_FILE."

# --- 3. DE-DUPLICATION (sort -u) ---
echo "=================================================="
echo "✨ Starting Step 2: De-duplicating URLs..."
echo "=================================================="

sort -u "$JS_URLS_FILE" -o "$UNIQUE_JS_URLS_FILE"

UNIQUE_COUNT=$(wc -l < "$UNIQUE_JS_URLS_FILE" | tr -d '[:space:]')

echo "✅ De-duplication complete. $UNIQUE_COUNT unique URLs saved to $UNIQUE_JS_URLS_FILE."

# --- 4. PARALLEL DOWNLOAD (wget + xargs) ---
echo "=================================================="
echo "⬇️ Starting Step 3: Parallel download of unique JS files..."
echo "=================================================="

# Create and navigate to the download directory
mkdir -p "$DOWNLOAD_DIR"
cd "$DOWNLOAD_DIR"

# Use xargs to execute wget commands in parallel
# -P $PARALLEL_JOBS: Set parallel download limit
# -n 1: Pass one URL at a time
# -q: Quiet mode (no output)
# -T $TIMEOUT_SECONDS: Set connection timeout
# -nd: No host-prefixed directories
# -nc: No clobber (don't overwrite existing files)

cat "../$UNIQUE_JS_URLS_FILE" | xargs -P "$PARALLEL_JOBS" -n 1 \
wget -q -T "$TIMEOUT_SECONDS" -nd -nc

DOWNLOADED_COUNT=$(ls -1 | wc -l | tr -d '[:space:]')

echo "✅ Download process complete."
echo "Found $DOWNLOADED_COUNT files in the '$DOWNLOAD_DIR' directory."

# Return to the original directory
cd ..

echo "=================================================="
echo "🎉 Automation Complete! Ready for Source Code Analysis."
echo "=================================================="