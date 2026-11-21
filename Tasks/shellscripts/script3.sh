
#!/bin/bash

# Q3: Linux User Validation

echo "Enter username:"
read -r username

if id "$username" &>/dev/null
then
    echo "User exists!"

    echo "User ID (UID):"
    id -u "$username"

    echo "Primary Group:"
    id -gn "$username"
else
    echo "User does not exist!"
fi

