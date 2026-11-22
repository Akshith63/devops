
#!/bin/bash

# Configuration
SERVICE_NAME="$1"
LOG_FILE="service_monitor.log"
ADMIN_EMAIL="admin@example.com"
NOTIFY_METHOD="terminal"

# Check whether service name is provided
if [ -z "$SERVICE_NAME" ]; then
    echo "Usage: $0 <service_name>"
    exit 1
fi

# Check whether service exists
if ! systemctl list-unit-files "${SERVICE_NAME}.service" --no-legend | grep -q "^${SERVICE_NAME}.service"; then
    echo "Error: Invalid service name: $SERVICE_NAME"
    exit 1
fi

# Check service status
if systemctl is-active --quiet "$SERVICE_NAME"; then
    echo "INFO: $SERVICE_NAME is running."
else
    # Generate alert message
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    ALERT="[$TIMESTAMP] ALERT: Service $SERVICE_NAME is inactive!"

    # Display alert
    echo "$ALERT"

    # Write incident to log file
    echo "$ALERT" >> "$LOG_FILE"

    # Notify administrator
    case "$NOTIFY_METHOD" in
        terminal)
            echo "Notification sent to administrator through terminal."
            ;;
        email)
            echo "$ALERT" | mail -s "Service Alert: $SERVICE_NAME" "$ADMIN_EMAIL"
            ;;
        *)
            echo "Invalid notification method."
            exit 1
            ;;
    esac
fi

