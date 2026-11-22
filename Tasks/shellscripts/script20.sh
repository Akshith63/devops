
#!/bin/bash

# Application log file
LOG_FILE="application1.log"

# Check whether log file exists
if [ ! -f "$LOG_FILE" ]; then
    echo "Error: Log file not found!"
    exit 1
fi

# Count log levels
ERROR_COUNT=$(grep -c '\[ERROR\]' "$LOG_FILE")
WARNING_COUNT=$(grep -c '\[WARNING\]' "$LOG_FILE")
INFO_COUNT=$(grep -c '\[INFO\]' "$LOG_FILE")

# Display log summary
echo "===== APPLICATION LOG ANALYSIS ====="
echo "Total ERROR entries: $ERROR_COUNT"
echo "Total WARNING entries: $WARNING_COUNT"
echo "Total INFO entries: $INFO_COUNT"

# Identify five most frequent error messages
echo ""
echo "===== TOP 5 FREQUENT ERROR MESSAGES ====="

awk -F '\\[ERROR\\] ' '/\[ERROR\]/ {print $2}' "$LOG_FILE" |
    sort |
    uniq -c |
    sort -nr |
    head -n 5

