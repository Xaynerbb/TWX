#!/bin/bash
echo "This script deletes files which are older than 30 days"

# Use provided path or default to current directory
path="${1:-.}"

echo "Target path: $path"

# Validate path exists and is a directory
if [ ! -d "$path" ]; then
    echo "Error: path '$path' does not exist or is not a directory"
    exit 1
fi

# Find and delete files older than 30 days (only regular files). Print what is removed.
if find "$path" -type f -mtime +30 -print -delete; then
    echo "Files have been successfully deleted"
else
    echo "Deletion was unsuccessful due to some issues"
    exit 1
fi