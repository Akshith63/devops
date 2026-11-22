
#!/bin/bash

# Directory to search
TARGET_DIR="$1"

# Report file
REPORT="old_files_report.txt"

# Check whether directory is provided
if [ -z "$TARGET_DIR" ]; then
    echo "Usage: $0 <directory_path>"
    exit 1
fi

# Check whether directory exists
if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Directory does not exist!"
    exit 1
fi

# Create report
echo "===== OLD FILE IDENTIFICATION REPORT =====" > "$REPORT"
echo "Directory: $TARGET_DIR" >> "$REPORT"
echo "Date: $(date)" >> "$REPORT"
echo "Files older than 7 days:" >> "$REPORT"
echo "----------------------------------------" >> "$REPORT"

# Search for files older than 7 days
find "$TARGET_DIR" -type f -mtime +7 -exec stat -c '%n | %s bytes | %y' {} \; >> "$REPORT"

# Display report
echo ""
echo "Old file identification completed!"
echo "Report saved in: $REPORT"
echo ""
cat "$REPORT"



