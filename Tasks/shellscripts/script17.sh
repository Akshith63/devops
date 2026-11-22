#!/bin/bash

# Input file containing server addresses
SERVER_FILE="server.txt"

# Output files
REACHABLE="reachable.txt"
UNREACHABLE="unreachable.txt"

# SSH connection timeout in seconds
TIMEOUT=5

# Check whether input file exists
if [ ! -f "$SERVER_FILE" ]; then
    echo "Error: $SERVER_FILE not found!"
    exit 1
fi

# Clear previous results
> "$REACHABLE"
> "$UNREACHABLE"

# Read server addresses from file
while IFS= read -r server || [ -n "$server" ]
do
    # Skip empty lines
    [ -z "$server" ] && continue

    echo "Checking SSH connectivity to $server..."

    # Test SSH connectivity
    if ssh -o BatchMode=yes \
           -o ConnectTimeout="$TIMEOUT" \
           -o StrictHostKeyChecking=accept-new \
           "$server" "exit" 2>/dev/null; then

        echo "$server" >> "$REACHABLE"
        echo "$server is REACHABLE"

    else
        echo "$server" >> "$UNREACHABLE"
        echo "$server is UNREACHABLE"
    fi

done < "$SERVER_FILE"

# Display summary
echo ""
echo "===== SSH CONNECTIVITY SUMMARY ====="
echo "Reachable servers:"
cat "$REACHABLE"

echo ""
echo "Unreachable servers:"
cat "$UNREACHABLE"

echo ""
echo "Results saved successfully!"
