
#!/bin/bash

# Accept command-line arguments
SOURCE_DIR="$1"
BACKUP_DIR="$2"

# Check whether both arguments are provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <source_directory> <backup_destination>"
    exit 1
fi

# Check whether source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory does not exist!"
    exit 1
fi

# Create backup destination if it does not exist
mkdir -p "$BACKUP_DIR"

if [ $? -ne 0 ]; then
    echo "Error: Could not create backup destination!"
    exit 1
fi

# Generate timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Create backup filename
BACKUP_FILE="$BACKUP_DIR/backup_$TIMESTAMP.tar.gz"

# Create compressed archive
tar -czf "$BACKUP_FILE" -C "$(dirname "$SOURCE_DIR")" "$(basename "$SOURCE_DIR")"

# Check whether archive creation was successful
if [ $? -eq 0 ]; then
    echo "Backup created successfully!"
else
    echo "Error: Backup creation failed!"
    exit 1
fi

# Verify archive exists
if [ -f "$BACKUP_FILE" ]; then

    # Verify archive readability
    if tar -tzf "$BACKUP_FILE" > /dev/null 2>&1; then
        echo "Archive verification successful!"
        echo "Backup file: $BACKUP_FILE"
        echo "Backup size: $(du -h "$BACKUP_FILE" | awk '{print $1}')"
    else
        echo "Error: Archive is not readable!"
        exit 1
    fi

else
    echo "Error: Backup archive not found!"
    exit 1
fi

