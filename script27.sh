
#!/bin/bash

# Q27: Configuration File Comparison

OLD_FILE="$1"
NEW_FILE="$2"
REPORT="config_comparison_report.txt"

# Validate input arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <old_config_file> <new_config_file>"
    exit 1
fi

# Check whether both files exist
if [ ! -f "$OLD_FILE" ] || [ ! -f "$NEW_FILE" ]; then
    echo "ERROR: One or both configuration files do not exist."
    exit 1
fi

# Check whether both files are readable
if [ ! -r "$OLD_FILE" ] || [ ! -r "$NEW_FILE" ]; then
    echo "ERROR: Cannot read one or both configuration files."
    exit 1
fi

# Create temporary diff file
TEMP_FILE=$(mktemp)

# Compare configuration files
diff -U0 "$OLD_FILE" "$NEW_FILE" > "$TEMP_FILE"
DIFF_STATUS=$?

if [ "$DIFF_STATUS" -gt 1 ]; then
    echo "ERROR: File comparison failed."
    rm -f "$TEMP_FILE"
    exit 1
fi

# Generate comparison report
{
    echo "======================================"
    echo "   CONFIGURATION COMPARISON REPORT"
    echo "======================================"
    echo "Old File: $OLD_FILE"
    echo "New File: $NEW_FILE"
    echo ""

    awk '
    function print_changes(    i, count) {
        count = (old_count < new_count ? old_count : new_count)

        for (i = 1; i <= count; i++) {
            print "MODIFIED:"
            print "  Old: " old_lines[i]
            print "  New: " new_lines[i]
            print ""
        }

        for (i = count + 1; i <= old_count; i++) {
            print "REMOVED: " old_lines[i]
        }

        for (i = count + 1; i <= new_count; i++) {
            print "ADDED: " new_lines[i]
        }

        old_count = 0
        new_count = 0
    }

    /^@@/ {
        print_changes()
        next
    }

    /^\+\+\+/ || /^---/ {
        next
    }

    /^\+/ {
        new_lines[++new_count] = substr($0, 2)
        next
    }

    /^-/ {
        old_lines[++old_count] = substr($0, 2)
        next
    }

    END {
        print_changes()
    }
    ' "$TEMP_FILE"

    echo ""
    echo "======================================"
    echo "Comparison completed."
    echo "======================================"

} > "$REPORT"

rm -f "$TEMP_FILE"

echo "Configuration comparison completed!"
echo "Report generated: $REPORT"

