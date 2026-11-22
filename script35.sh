
#!/bin/bash

# Retry a failed endpoint using while loop

URL="https://example.com"
MAX_RETRIES=5
COUNT=1

echo "Checking endpoint: $URL"

while [ $COUNT -le $MAX_RETRIES ]
do
    echo "Attempt $COUNT of $MAX_RETRIES"

    # Check endpoint availability
    if curl -s --connect-timeout 5 -o /dev/null "$URL"; then
        echo "SUCCESS: Endpoint is available."
        break
    else
        echo "WARNING: Endpoint is unavailable."
    fi

    # Demonstrate continue
    if [ $COUNT -eq 2 ]; then
        echo "Skipping the remaining steps for attempt 2."
        COUNT=$((COUNT + 1))
        continue
    fi

    # Demonstrate until
    until [ $COUNT -gt 2 ]
    do
        echo "Waiting before next retry..."
        sleep 2
        break
    done

    COUNT=$((COUNT + 1))
done

if [ $COUNT -gt $MAX_RETRIES ] && ! curl -s --connect-timeout 5 -o /dev/null "$URL"; then
    echo "ERROR: Endpoint failed after $MAX_RETRIES attempts."
fi

