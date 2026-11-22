
#!/bin/bash

# API URL
API_URL="https://jsonplaceholder.typicode.com/posts/1"

# Retry configuration
MAX_RETRIES=5
DELAY=3

# Attempt counter
attempt=1

# API retry loop
while [ "$attempt" -le "$MAX_RETRIES" ]
do
    echo "API request attempt: $attempt"

    # Call API and capture HTTP status code
    HTTP_STATUS=$(curl -sS -o /tmp/api_response.txt \
        -w "%{http_code}" \
        --connect-timeout 5 \
        --max-time 10 \
        "$API_URL")

    # Check API response
    if [ "$HTTP_STATUS" -ge 200 ] && [ "$HTTP_STATUS" -lt 300 ] 2>/dev/null; then
        echo "API request successful!"
        echo "HTTP Status Code: $HTTP_STATUS"
        cat /tmp/api_response.txt
        exit 0
    else
        echo "API request failed. HTTP Status: ${HTTP_STATUS:-Connection Error}"
    fi

    # Stop after maximum attempts
    if [ "$attempt" -eq "$MAX_RETRIES" ]; then
        break
    fi

    echo "Retrying after $DELAY seconds..."
    sleep "$DELAY"

    attempt=$((attempt + 1))
done

echo "ERROR: API request failed after $MAX_RETRIES attempts."
exit 1

