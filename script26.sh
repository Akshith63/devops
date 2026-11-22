
#!/bin/bash

# Q26: Interactive Service Management Menu

# Approved test service
SERVICE="cron"

# Check whether the user is authorized
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: Please run this script using sudo."
    exit 1
fi

# Check whether systemctl is available
if ! command -v systemctl >/dev/null 2>&1; then
    echo "ERROR: systemctl command not found."
    exit 1
fi

# Check whether the service exists
if ! systemctl list-unit-files "${SERVICE}.service" --no-legend |
    grep -q "^${SERVICE}.service"; then
    echo "ERROR: Service $SERVICE not found."
    exit 1
fi

while true
do
    echo ""
    echo "=================================="
    echo "     SERVICE MANAGEMENT MENU"
    echo "=================================="
    echo "Service: $SERVICE"
    echo "1. Check Service Status"
    echo "2. Start Service"
    echo "3. Stop Service"
    echo "4. Restart Service"
    echo "5. Exit"
    echo "=================================="

    read -rp "Enter your choice (1-5): " choice

    case "$choice" in

        1)
            echo "Checking service status..."
            systemctl status "$SERVICE" --no-pager
            ;;

        2)
            echo "Starting $SERVICE..."
            if systemctl start "$SERVICE"; then
                echo "SUCCESS: Service started."
            else
                echo "ERROR: Failed to start service."
            fi
            ;;

        3)
            echo "Stopping $SERVICE..."
            if systemctl stop "$SERVICE"; then
                echo "SUCCESS: Service stopped."
            else
                echo "ERROR: Failed to stop service."
            fi
            ;;

        4)
            echo "Restarting $SERVICE..."
            if systemctl restart "$SERVICE"; then
                echo "SUCCESS: Service restarted."
            else
                echo "ERROR: Failed to restart service."
            fi
            ;;

        5)
            echo "Exiting Service Management Menu."
            exit 0
            ;;

        *)
            echo "INVALID INPUT: Please enter a number between 1 and 5."
            ;;
    esac

done

