
#!/bin/bash

# Q24: Deployment Configuration Validation

echo "=================================="
echo " Deployment Configuration Check"
echo "=================================="

ERRORS=0

# 1. Validate mandatory environment variables
echo ""
echo "Checking environment variables..."

if [ -z "$APP_ENV" ]; then
    echo "ERROR: APP_ENV is not set"
    ERRORS=$((ERRORS + 1))
else
    echo "APP_ENV: $APP_ENV"
fi

if [ -z "$DB_HOST" ]; then
    echo "ERROR: DB_HOST is not set"
    ERRORS=$((ERRORS + 1))
else
    echo "DB_HOST: $DB_HOST"
fi

# 2. Validate configuration files
echo ""
echo "Checking configuration files..."

CONFIG_FILE="./config.env"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: Configuration file $CONFIG_FILE not found"
    ERRORS=$((ERRORS + 1))
elif [ ! -r "$CONFIG_FILE" ]; then
    echo "ERROR: Configuration file is not readable"
    ERRORS=$((ERRORS + 1))
else
    echo "Configuration file exists and is readable"
fi

# 3. Validate application port
echo ""
echo "Checking application port..."

APP_PORT="${APP_PORT:-8080}"

if ! [[ "$APP_PORT" =~ ^[0-9]+$ ]] || 
   [ "$APP_PORT" -lt 1 ] || [ "$APP_PORT" -gt 65535 ]; then
    echo "ERROR: Invalid application port: $APP_PORT"
    ERRORS=$((ERRORS + 1))
else
    echo "Application port $APP_PORT is valid"
fi

# 4. Validate directory permissions
echo ""
echo "Checking deployment directory..."

DEPLOY_DIR="./deployment"

if [ ! -d "$DEPLOY_DIR" ]; then
    echo "ERROR: Deployment directory not found"
    ERRORS=$((ERRORS + 1))
elif [ ! -w "$DEPLOY_DIR" ] || [ ! -x "$DEPLOY_DIR" ]; then
    echo "ERROR: Deployment directory lacks write or access permission"
    ERRORS=$((ERRORS + 1))
else
    echo "Deployment directory permissions are valid"
fi

# Final validation result
echo ""
echo "=================================="

if [ "$ERRORS" -gt 0 ]; then
    echo "Deployment validation FAILED!"
    echo "Total errors: $ERRORS"
    echo "Deployment stopped."
    exit 1
else
    echo "All validations passed!"
    echo "Deployment can proceed."
    exit 0
fi

