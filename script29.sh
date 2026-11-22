
#!/bin/bash

# Q29: Website Availability Monitoring

URL_FILE="urls.txt"
REPORT_FILE="website_monitoring_report.csv"

# Response time threshold in seconds
SLOW_THRESHOLD=2

echo "======================================"
echo "     WEBSITE AVAILABILITY MONITOR"
echo "======================================"

# Check whether URL file exists
if [ ! -f "$URL_FILE" ]; then
    echo "ERROR: URL file not found!"
    exit 1
fi

# Check whether curl is installed
if ! command -v curl >/dev/null 2>&1; then
    echo "ERROR: curl is not installed!"
    exit 1
fi

# Create CSV report with header
echo "timestamp,url,http_code,response_time,status" > "$REPORT_FILE"

TOTAL=0
AVAILABLE=0
UNAVAILABLE=0
SLOW=0

# Read URLs from file
while IFS= read -r URL || [ -n "$URL" ]
do
    # Skip empty lines and comments
    [[ -z "$URL" || "$URL" == \#* ]] && continue

    TOTAL=$((TOTAL + 1))

    echo ""
    echo "Checking: $URL"

    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

    # Check HTTP code and response time
    RESULT=$(curl -L -sS -o /dev/null \
        --connect-timeout 5 \
        --max-time 15 \
        -w "%{http_code},%{time_total}" \
        "$URL" 2>/dev/null)

    CURL_STATUS=$?

    if [ "$CURL_STATUS" -ne 0 ]; then
        HTTP_CODE="000"
        RESPONSE_TIME="0.00"
        STATUS="UNAVAILABLE"
        UNAVAILABLE=$((UNAVAILABLE + 1))
    else
        HTTP_CODE="${RESULT%,*}"
        RESPONSE_TIME="${RESULT#*,}"

        # Check HTTP response code
        if [ "$HTTP_CODE" -ge 400 ] || [ "$HTTP_CODE" -eq 000 ]; then
            STATUS="UNAVAILABLE"
            UNAVAILABLE=$((UNAVAILABLE + 1))
        else
            STATUS="AVAILABLE"
            AVAILABLE=$((AVAILABLE + 1))

            # Check response time
            if awk -v time="$RESPONSE_TIME" \
                -v threshold="$SLOW_THRESHOLD" \
                'BEGIN { exit !(time > threshold) }'
            then
                STATUS="SLOW"
                SLOW=$((SLOW + 1))
            fi
        fi
    fi

    echo "HTTP Code: $HTTP_CODE"
    echo "Response Time: ${RESPONSE_TIME} seconds"
    echo "Status: $STATUS"

    # Append results to CSV report
    echo "\"$TIMESTAMP\",\"$URL\",\"$HTTP_CODE\",\"$RESPONSE_TIME\",\"$STATUS\"" >> "$REPORT_FILE"

done < "$URL_FILE"

echo ""
echo "======================================"
echo "       MONITORING SUMMARY"
echo "======================================"
echo "Total URLs checked: $TOTAL"
echo "Available websites: $AVAILABLE"
echo "Unavailable websites: $UNAVAILABLE"
echo "Slow websites: $SLOW"
echo "Report generated: $REPORT_FILE"
echo "======================================"

