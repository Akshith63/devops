
#!/bin/bash

# Q5: Memory Utilization Checker

if ! command -v free >/dev/null 2>&1; then
    echo "Error: 'free' command not found. Run this script on Linux or WSL."
    exit 1
fi

# Collect memory information in MiB
read -r total used available < <(
    free -m | awk '/^Mem:/ {print $2, $3, $7}'
)

# Calculate memory utilization percentage
usage=$(awk -v used="$used" -v total="$total" \
    'BEGIN {if (total > 0) printf "%.2f", (used/total)*100}')

echo "----- Memory Utilization Report -----"
echo "Total Memory     : ${total} MiB"
echo "Used Memory      : ${used} MiB"
echo "Available Memory : ${available} MiB"
echo "Utilization      : ${usage}%"

# Check whether usage exceeds 80%
if awk -v usage="$usage" 'BEGIN {exit !(usage > 80)}'
then
    echo "Status: WARNING - Memory usage exceeds 80%!"
else
    echo "Status: NORMAL - Memory usage is within limits."
fi

