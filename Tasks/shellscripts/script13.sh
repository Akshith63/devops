
#!/bin/bash

# Configurable CPU threshold
THRESHOLD=80

# Function to check CPU utilization
check_cpu() {
    cpu_usage=$1

    if [ "$cpu_usage" -le "$THRESHOLD" ]; then
        echo "CPU utilization is normal: ${cpu_usage}%"
        return 0
    else
        echo "WARNING: High CPU utilization: ${cpu_usage}%"
        return 1
    fi
}

# Call the function
check_cpu "$1"

# Check function return status
if [ $? -eq 0 ]; then
    echo "Server health: SUCCESS"
else
    echo "Server health: FAILURE"
fi

