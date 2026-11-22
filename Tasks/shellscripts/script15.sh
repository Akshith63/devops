
#!/bin/bash

# Define application log file
LOG_FILE="application.log"

# Function to write log messages
write_log() {
    level=$1
    message=$2
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")

    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}

# Write five events to the log file
write_log "INFO" "Application started"
write_log "INFO" "Server connected successfully"
write_log "WARNING" "High memory usage detected"
write_log "ERROR" "Database connection failed"
write_log "INFO" "Application stopped"

echo "Five events written successfully to $LOG_FILE"

