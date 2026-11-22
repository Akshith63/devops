
#!/bin/bash

# Configurable thresholds
CPU_WARNING=70
CPU_CRITICAL=90

MEM_WARNING=70
MEM_CRITICAL=90

DISK_WARNING=70
DISK_CRITICAL=90

# Collect CPU utilization
CPU_IDLE=$(top -bn1 | grep "Cpu(s)" | awk '{print $8}' | cut -d'.' -f1)
CPU_USAGE=$((100 - CPU_IDLE))

# Collect memory utilization
MEM_USAGE=$(free | awk '/Mem:/ {printf "%.0f", $3/$2 * 100}')

# Collect disk utilization of root filesystem
DISK_USAGE=$(df / | awk 'NR==2 {gsub("%","",$5); print $5}')

# Display resource utilization
echo "===== SERVER HEALTH MONITORING ====="
echo "CPU Usage: $CPU_USAGE%"
echo "Memory Usage: $MEM_USAGE%"
echo "Disk Usage: $DISK_USAGE%"

# Function to check thresholds
check_status() {
    usage=$1
    warning=$2
    critical=$3

    if [ "$usage" -ge "$critical" ]; then
        echo "CRITICAL"
    elif [ "$usage" -ge "$warning" ]; then
        echo "WARNING"
    else
        echo "HEALTHY"
    fi
}

# Check individual resource status
CPU_STATUS=$(check_status "$CPU_USAGE" "$CPU_WARNING" "$CPU_CRITICAL")
MEM_STATUS=$(check_status "$MEM_USAGE" "$MEM_WARNING" "$MEM_CRITICAL")
DISK_STATUS=$(check_status "$DISK_USAGE" "$DISK_WARNING" "$DISK_CRITICAL")

echo ""
echo "===== RESOURCE STATUS ====="
echo "CPU Status: $CPU_STATUS"
echo "Memory Status: $MEM_STATUS"
echo "Disk Status: $DISK_STATUS"

# Determine overall server health
if [[ "$CPU_STATUS" == "CRITICAL" || "$MEM_STATUS" == "CRITICAL" || "$DISK_STATUS" == "CRITICAL" ]]; then
    OVERALL_STATUS="CRITICAL"
elif [[ "$CPU_STATUS" == "WARNING" || "$MEM_STATUS" == "WARNING" || "$DISK_STATUS" == "WARNING" ]]; then
    OVERALL_STATUS="WARNING"
else
    OVERALL_STATUS="HEALTHY"
fi

echo ""
echo "Overall Server Health: $OVERALL_STATUS"

