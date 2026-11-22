
#!/bin/bash

# Q25: CSV-Based Server Health Analysis

CSV_FILE="servers.csv"
REPORT_FILE="unhealthy_servers_report.csv"

# Utilization thresholds
CPU_THRESHOLD=80
MEMORY_THRESHOLD=80
DISK_THRESHOLD=80

echo "=================================="
echo "     Server Health Analysis"
echo "=================================="

# Check whether CSV file exists
if [ ! -f "$CSV_FILE" ]; then
    echo "ERROR: CSV file not found!"
    exit 1
fi

# Create report with header
echo "hostname,cpu,memory,disk,reason" > "$REPORT_FILE"

UNHEALTHY_COUNT=0

# Read CSV file and skip header
while IFS=',' read -r hostname cpu memory disk
do
    # Skip header and empty lines
    [ "$hostname" = "hostname" ] && continue
    [ -z "$hostname" ] && continue

    REASONS=""

    # Check CPU utilization
    if [ "$cpu" -gt "$CPU_THRESHOLD" ]; then
        REASONS+="High CPU "
    fi

    # Check memory utilization
    if [ "$memory" -gt "$MEMORY_THRESHOLD" ]; then
        REASONS+="High Memory "
    fi

    # Check disk utilization
    if [ "$disk" -gt "$DISK_THRESHOLD" ]; then
        REASONS+="High Disk "
    fi

    # Add unhealthy servers to report
    if [ -n "$REASONS" ]; then
        echo "$hostname,$cpu,$memory,$disk,$REASONS" >> "$REPORT_FILE"

        echo "UNHEALTHY: $hostname"
        echo "Reason: $REASONS"

        UNHEALTHY_COUNT=$((UNHEALTHY_COUNT + 1))
    else
        echo "HEALTHY: $hostname"
    fi

done < "$CSV_FILE"

echo ""
echo "=================================="
echo "Total unhealthy servers: $UNHEALTHY_COUNT"
echo "Report generated: $REPORT_FILE"
echo "=================================="

