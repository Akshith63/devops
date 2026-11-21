
#!/bin/bash

# Q4: CPU Utilization Threshold Checker

echo "Enter CPU utilization percentage:"
read -r cpu

if ! [[ "$cpu" =~ ^[0-9]+([.][0-9]+)?$ ]] || ! awk -v n="$cpu" 'BEGIN {exit !(n >= 0 && n <= 100)}'
then
    echo "Invalid input! Enter a number between 0 and 100."
elif awk -v n="$cpu" 'BEGIN {exit !(n < 70)}'
then
    echo "CPU Utilization: NORMAL"
elif awk -v n="$cpu" 'BEGIN {exit !(n <= 85)}'
then
    echo "CPU Utilization: WARNING"
else
    echo "CPU Utilization: CRITICAL"
fi

