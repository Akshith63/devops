
#!/bin/bash

# Accept domain name
DOMAIN="$1"

# Warning threshold in days
THRESHOLD=30

# Check whether domain is provided
if [ -z "$DOMAIN" ]; then
    echo "Usage: $0 <domain_name>"
    exit 1
fi

echo "Checking SSL certificate for: $DOMAIN"

# Retrieve certificate expiry date
EXPIRY_DATE=$(echo | openssl s_client \
    -servername "$DOMAIN" \
    -connect "$DOMAIN:443" 2>/dev/null |
    openssl x509 -noout -enddate 2>/dev/null |
    cut -d= -f2)

# Check whether certificate was retrieved
if [ -z "$EXPIRY_DATE" ]; then
    echo "Error: Unable to retrieve SSL certificate!"
    exit 1
fi

# Convert expiry date into Unix timestamp
EXPIRY_TIMESTAMP=$(date -d "$EXPIRY_DATE" +%s 2>/dev/null)

if [ -z "$EXPIRY_TIMESTAMP" ]; then
    echo "Error: Unable to parse certificate expiry date!"
    exit 1
fi

# Get current timestamp
CURRENT_TIMESTAMP=$(date +%s)

# Calculate remaining days
REMAINING_SECONDS=$((EXPIRY_TIMESTAMP - CURRENT_TIMESTAMP))
REMAINING_DAYS=$((REMAINING_SECONDS / 86400))

# Display certificate information
echo "Certificate Expiry Date: $EXPIRY_DATE"
echo "Remaining Validity: $REMAINING_DAYS days"

# Check certificate expiry status
if [ "$REMAINING_SECONDS" -lt 0 ]; then
    echo "CRITICAL: SSL certificate has expired!"
elif [ "$REMAINING_DAYS" -le "$THRESHOLD" ]; then
    echo "WARNING: SSL certificate expires within 30 days!"
else
    echo "SUCCESS: SSL certificate is valid."
fi

