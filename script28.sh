
#!/bin/bash

# Q28: Automated Server Health Report

REPORT_FILE="server_health_report.csv"

echo "======================================"
echo "     AUTOMATED SERVER HEALTH REPORT"
echo "======================================"

# 1. Collect timestamp
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# 2. Collect hostname
HOSTNAME=$(hostname)

# 3. Collect IP address
IP_ADDRESS=$(hostname -I | awk '{print $1}')

if [ -z "$IP_ADDRESS" ]; then
    IP_ADDRESS="Not Available"
fi

# 4. Collect system uptime
UPTIME=$(uptime -p)

# 5. Collect CPU utilization
read cpu user nice system idle iowait irq softirq steal rest < /proc/stat
IDLE1=$((idle + iowait))
TOTAL1=$((user + nice + system + idle + iowait + irq + softirq + steal))

sleep 1

read cpu user nice system idle iowait irq softirq steal rest < /proc/stat
IDLE2=$((idle + iowait))
TOTAL2=$((user + nice + system + idle + iowait + irq + softirq + steal))

CPU_UTILIZATION=$(awk -v t1="$TOTAL1" -v t2="$TOTAL2" \
-v i1="$IDLE1" -v i2="$IDLE2" \
'BEGIN {
    total = t2 - t1
    idle = i2 - i1
    if (total > 0)
        printf "%.2f", (total - idle) * 100 / total
    else
        print "0.00"
}')

# 6. Collect memory utilization
MEMORY_UTILIZATION=$(awk '
/MemTotal:/ {total=$2}
/MemAvailable:/ {available=$2}
END {
    if (total > 0)
        printf "%.2f", (total - available) * 100 / total
    else
        print "0.00"
}' /proc/meminfo)

# 7. Collect disk utilization
DISK_UTILIZATION=$(df -P / | awk 'NR==2 {
    gsub("%", "", $5)
    print $5
}')

# Create CSV header if report does not exist
if [ ! -f "$REPORT_FILE" ]; then
    echo "timestamp,hostname,ip_address,uptime,cpu_utilization,memory_utilization,disk_utilization" > "$REPORT_FILE"
fi

# Append collected information to CSV
echo "\"$TIMESTAMP\",\"$HOSTNAME\",\"$IP_ADDRESS\",\"$UPTIME\",\"$CPU_UTILIZATION%\",\"$MEMORY_UTILIZATION%\",\"$DISK_UTILIZATION%\"" >> "$REPORT_FILE"

# Display collected information
echo "Timestamp: $TIMESTAMP"
echo "Hostname: $HOSTNAME"
echo "IP Address: $IP_ADDRESS"
echo "Uptime: $UPTIME"
echo "CPU Utilization: $CPU_UTILIZATION%"
echo "Memory Utilization: $MEMORY_UTILIZATION%"
echo "Disk Utilization: $DISK_UTILIZATION%"

echo ""
echo "Health report saved successfully!"
echo "Report file: $REPORT_FILE"
echo "======================================"

