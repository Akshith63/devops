
#!/bin/bash

# Q30: Scheduled Daily Log Report

LOG_FILE="./application.log"
REPORT_DIR="./reports"

# Get previous day's date
YESTERDAY=$(date -d "yesterday" '+%Y-%m-%d')

# Generate timestamp
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Create report directory if it does not exist
mkdir -p "$REPORT_DIR"

# Report filename
REPORT_FILE="$REPORT_DIR/daily_log_report_${YESTERDAY}.txt"

echo "======================================" > "$REPORT_FILE"
echo "       DAILY APPLICATION LOG REPORT" >> "$REPORT_FILE"
echo "======================================" >> "$REPORT_FILE"

echo "Report Generated: $TIMESTAMP" >> "$REPORT_FILE"
echo "Log Date: $YESTERDAY" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Check whether log file exists
if [ ! -f "$LOG_FILE" ]; then
    echo "ERROR: Application log file not found!" 
    exit 1
fi

# Count errors from previous day
ERROR_COUNT=$(grep "^$YESTERDAY" "$LOG_FILE" |
    grep -c "ERROR")

# Count warnings from previous day
WARNING_COUNT=$(grep "^$YESTERDAY" "$LOG_FILE" |
    grep -c "WARNING")

# Count total log entries from previous day
TOTAL_COUNT=$(grep -c "^$YESTERDAY" "$LOG_FILE")

# Generate report
{
    echo "Total Log Entries: $TOTAL_COUNT"
    echo "Total Errors: $ERROR_COUNT"
    echo "Total Warnings: $WARNING_COUNT"
    echo ""
    echo "------------- ERROR DETAILS -------------"

    grep "^$YESTERDAY" "$LOG_FILE" | grep "ERROR" || true

    echo ""
    echo "------------ WARNING DETAILS ------------"

    grep "^$YESTERDAY" "$LOG_FILE" | grep "WARNING" || true

    echo ""
    echo "======================================"
    echo "          REPORT COMPLETED"
    echo "======================================"

} >> "$REPORT_FILE"

echo "Daily log analysis completed!"
echo "Report generated: $REPORT_FILE"
echo "Errors: $ERROR_COUNT"
echo "Warnings: $WARNING_COUNT"

