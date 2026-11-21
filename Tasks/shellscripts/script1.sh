
#!/bin/bash

# Q1: File Existence Checker

echo "Enter the filename:"
read -r filename

if [ -f "$filename" ]
then
    echo "File exists!"

    echo "File size:"
    stat -c "%s bytes" -- "$filename"

    echo "File permissions:"
    stat -c "%A (%a)" -- "$filename"
else
    echo "File does not exist!"
fi

