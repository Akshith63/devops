
#!/bin/bash

# Set default port if APP_PORT is not provided
APP_PORT=${APP_PORT:-8080}

# Check whether APP_ENV is provided
if [ -z "$APP_ENV" ]; then
    echo "Error: APP_ENV is not set."
    echo "Allowed values: dev, qa, prod"
    exit 1
fi

# Validate APP_ENV
case "$APP_ENV" in
    dev|qa|prod)
        echo "Application Environment: $APP_ENV"
        echo "Application Port: $APP_PORT"
        echo "Environment validation successful!"
        ;;
    *)
        echo "Error: Invalid APP_ENV: $APP_ENV"
        echo "Allowed values: dev, qa, prod"
        exit 1
        ;;
esac

