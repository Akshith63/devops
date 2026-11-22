
#!/bin/bash

# Check whether both arguments are provided
if [ $# -ne 2 ]; then
    echo "Error: Please provide both arguments."
    echo "Usage: $0 <username> <environment>"
    exit 1
fi

# Store command-line arguments
username=$1
environment=$2

# Display the details
echo "Username: $username"
echo "Environment: $environment"
echo "Both arguments provided successfully!"

