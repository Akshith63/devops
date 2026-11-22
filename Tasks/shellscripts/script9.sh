
#!/bin/bash

# Create multiple directories using for loop

for dir in development testing staging production
do
    mkdir -p "$dir"

    if [ -d "$dir" ]; then
        echo "$dir directory created successfully"
    else
        echo "Failed to create $dir directory"
    fi
done

