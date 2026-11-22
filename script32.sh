
#!/bin/bash

# Q32: Automated Log Rotation and Retention

# Configuration
LOG_DIR="./application_logs"
ARCHIVE_DIR="./archives"
ERROR_LOG="./log_rotation_errors.log"

MIN_AGE_DAYS=1
RETENTION_DAYS=7

# Dry-run is enabled by default
MODE="DRY_RUN"

# Allow explicit execution
if [ "$1" = "--execute" ]; then
    MODE="EXECUTE"
elif [ "$1" = "--dry-run" ] || [ -z "$1" ]; then
    MODE="DRY_RUN"
else
    echo "Usage: $0 [--dry-run | --execute]"
    exit 1
fi

# Check required commands
for CMD in find gzip fuser date; do
    if ! command -v "$CMD" >/dev/null 2>&1; then
        echo "ERROR: Required command $CMD is missing."
        exit 1
    fi
done

# Validate directories
if [ ! -d "$LOG_DIR" ]; then
    echo "ERROR: Log directory $LOG_DIR not found."
    exit 1
fi

mkdir -p "$ARCHIVE_DIR" || exit 1

# Validate retention settings
if ! [[ "$MIN_AGE_DAYS" =~ ^[0-9]+$ ]] ||
   ! [[ "$RETENTION_DAYS" =~ ^[0-9]+$ ]]; then
    echo "ERROR: Retention values must be non-negative integers."
    exit 1
fi

# Error logging function
log_error() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') ERROR: $1" >> "$ERROR_LOG"
    echo "ERROR: $1"
}

# Counters
TOTAL=0
ARCHIVED=0
SKIPPED=0
DELETED=0
FAILED=0

echo "======================================"
echo "       AUTOMATED LOG ROTATION"
echo "======================================"
echo "Mode: $MODE"
echo "Log directory: $LOG_DIR"
echo "Archive directory: $ARCHIVE_DIR"
echo "Minimum log age: $MIN_AGE_DAYS days"
echo "Archive retention: $RETENTION_DAYS days"
echo "======================================"

# Find old log files
while IFS= read -r -d '' FILE
do
    TOTAL=$((TOTAL + 1))

    echo ""
    echo "Checking: $FILE"

    # Protect active log files
    if fuser -s "$FILE" >/dev/null 2>&1; then
        echo "SKIPPED: Log file is currently in use."
        SKIPPED=$((SKIPPED + 1))
        continue
    fi

    BASENAME=$(basename "$FILE")
    TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
    ARCHIVE="$ARCHIVE_DIR/${BASENAME}.${TIMESTAMP}.gz"

    if [ "$MODE" = "DRY_RUN" ]; then
        echo "DRY RUN: Would compress and archive $FILE"
        echo "DRY RUN: Archive destination: $ARCHIVE"
        ARCHIVED=$((ARCHIVED + 1))
        continue
    fi

    # Compress the log into the archive directory
    if gzip -c -- "$FILE" > "$ARCHIVE"; then

        # Verify compressed archive
        if gzip -t "$ARCHIVE"; then

            # Check again before removing the original
            if fuser -s "$FILE" >/dev/null 2>&1; then
                log_error "File became active during archiving: $FILE"
                rm -f -- "$ARCHIVE"
                SKIPPED=$((SKIPPED + 1))
                continue
            fi

            # Remove original only after successful compression
            if rm -- "$FILE"; then
                echo "ARCHIVED: $FILE"
                ARCHIVED=$((ARCHIVED + 1))
            else
                log_error "Unable to remove original file: $FILE"
                FAILED=$((FAILED + 1))
            fi

        else
            log_error "Archive verification failed: $ARCHIVE"
            rm -f -- "$ARCHIVE"
            FAILED=$((FAILED + 1))
        fi

    else
        log_error "Compression failed: $FILE"
        rm -f -- "$ARCHIVE"
        FAILED=$((FAILED + 1))
    fi

done < <(find "$LOG_DIR" -type f -name "*.log" \
    -mmin "+$((MIN_AGE_DAYS * 1440))" -print0)

# Apply archive retention policy
echo ""
echo "Checking expired archives..."

while IFS= read -r -d '' ARCHIVE
do
    if [ "$MODE" = "DRY_RUN" ]; then
        echo "DRY RUN: Would delete expired archive: $ARCHIVE"
        DELETED=$((DELETED + 1))
    else
        if rm -- "$ARCHIVE"; then
            echo "DELETED: $ARCHIVE"
            DELETED=$((DELETED + 1))
        else
            log_error "Unable to delete expired archive: $ARCHIVE"
            FAILED=$((FAILED + 1))
        fi
    fi

done < <(find "$ARCHIVE_DIR" -type f -name "*.gz" \
    -mtime "+$RETENTION_DAYS" -print0)

# Final summary
echo ""
echo "======================================"
echo "          ROTATION SUMMARY"
echo "======================================"
echo "Mode: $MODE"
echo "Log files checked: $TOTAL"
echo "Files archived/planned: $ARCHIVED"
echo "Files skipped: $SKIPPED"
echo "Archives deleted/planned: $DELETED"
echo "Failed operations: $FAILED"
echo "Error log: $ERROR_LOG"
echo "======================================"

if [ "$FAILED" -gt 0 ]; then
    exit 1
fi

exit 0

