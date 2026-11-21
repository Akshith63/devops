
#!/bin/bash

# Q2: Directory Creation Automation

echo "Enter directory path:"
read -r dir

if [ -d "$dir" ]
then
    echo "Directory already exists!"
else
    mkdir -p "$dir"
    echo "Directory created successfully!"
fi

