
#!/bin/bash

# Q31: Multi-Server Health Monitoring Automation

SERVER_FILE="servers.txt"
REPORT_FILE="multi_server_health_report.csv"
TIMEOUT=20

echo "======================================"
echo "   MULTI-SERVER HEALTH MONITORING"
echo "======================================"

# Check server list
if [ ! -f "$SERVER_FILE" ]; then
    echo "ERROR: Server list file not found!"
    exit 1
fi

# Check SSH and timeout commands
if ! command -v ssh >/dev/null 2>&1; then
    echo "ERROR: SSH command is not installed!"
    exit 1
fi

if ! command -v timeout >/dev/null 2>&1; then
    echo "ERROR: timeout command is not installed!"
    exit 1
fi

# Create CSV report
echo "timestamp,server,cpu,memory,disk,uptime,status" > "$REPORT_FILE"

TOTAL=0
SUCCESS=0
FAILED=0
TIMED_OUT=0

# Read server names from file
while IFS= read -r SERVER || [ -n "$SERVER" ]
do
    # Skip empty lines and comments
    [[ -z "$SERVER" || "$SERVER" == \#* ]] && continue

    TOTAL=$((TOTAL + 1))

    echo ""
    echo "Checking server: $SERVER"

    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

    # Connect through SSH and collect health information
    RESULT=$(timeout "${TIMEOUT}s" ssh \
        -o BatchMode=yes \
        -o ConnectTimeout=5 \
        -o StrictHostKeyChecking=accept-new \
        "$SERVER" 'bash -s' 2>/dev/null <<'REMOTE'

# CPU utilization calculation
read cpu user nice system idle iowait irq softirq steal rest < /proc/stat
IDLE1=$((idle + iowait))
TOTAL1=$((user + nice + system + idle + iowait + irq + softirq + steal))

sleep 1

read cpu user nice system idle iowait irq softirq steal rest < /proc/stat
IDLE2=$((idle + iowait))
TOTAL2=$((user + nice + system + idle + iowait + irq + softirq + steal))

CPU=$(awk -v t1="$TOTAL1" -v t2="$TOTAL2" \
-v i1="$IDLE1" -v i2="$IDLE2" \
'BEGIN {
    total=t2-t1
    idle=i2-i1
    if (total > 0)
        printf "%.2f", (total-idle)*100/total
    else
        print "0.00"
}')

# Memory utilization
MEMORY=$(awk '
/MemTotal:/ {total=$2}
/MemAvailable:/ {available=$2}
END {
    if (total > 0)
        printf "%.2f", (total-available)*100/total
    else
        print "0.00"
}' /proc/meminfo)

# Disk utilization
DISK=$(df -P / | awk 'NR==2 {
    gsub("%", "", $5)
    print $5
}')

# System uptime
UPTIME=$(uptime -p | tr ',' ' ')

# Return collected information
echo "$CPU|$MEMORY|$DISK|$UPTIME"

REMOTE
)

    COMMAND_STATUS=$?

    if [ "$COMMAND_STATUS" -eq 124 ]; then

        STATUS="TIMEOUT"
        FAILED=$((FAILED + 1))
        TIMED_OUT=$((TIMED_OUT + 1))

        echo "WARNING: Server command timed out."

        echo "\"$TIMESTAMP\",\"$SERVER\",\"\",\"\",\"\",\"\",\"$STATUS\"" >> "$REPORT_FILE"

    elif [ "$COMMAND_STATUS" -ne 0 ] || [ -z "$RESULT" ]; then

        STATUS="CONNECTION_FAILED"
        FAILED=$((FAILED + 1))

        echo "ERROR: Unable to connect to server."

        echo "\"$TIMESTAMP\",\"$SERVER\",\"\",\"\",\"\",\"\",\"$STATUS\"" >> "$REPORT_FILE"

    else

        IFS='|' read -r CPU MEMORY DISK UPTIME <<< "$RESULT"

        STATUS="SUCCESS"
        SUCCESS=$((SUCCESS + 1))

        echo "CPU Utilization: $CPU%"
        echo "Memory Utilization: $MEMORY%"
        echo "Disk Utilization: $DISK%"
        echo "Uptime: $UPTIME"

        echo "\"$TIMESTAMP\",\"$SERVER\",\"$CPU%\",\"$MEMORY%\",\"$DISK%\",\"$UPTIME\",\"$STATUS\"" >> "$REPORT_FILE"

    fi

done < "$SERVER_FILE"

# Final summary
echo ""
echo "======================================"
echo "       MONITORING SUMMARY"
echo "======================================"
echo "Total servers checked: $TOTAL"
echo "Successful connections: $SUCCESS"
echo "Failed connections: $FAILED"
echo "Command timeouts: $TIMED_OUT"
echo "Report generated: $REPORT_FILE"
echo "======================================"

