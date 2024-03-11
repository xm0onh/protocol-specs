#!/bin/bash

# Assuming your .env file is at the root of your repository
source "./.env"

date=$(date -u +"%m/%d/%Y")
author_name=$AUTHOR_NAME

# Check if AUTHOR_NAME is set
if [[ -z "$author_name" ]]; then
    echo "Error: Author name is empty."
    exit 1
fi

for file in $(git diff --cached --name-only | grep '\.md$'); do
    if [ "$file" == "README.md" ]; then
        continue
    fi
    awk -v date="$date" -v author="$author_name" '
        BEGIN {printed=0}
        /^---$/ {count++} # Count the number of occurrences of "---"
        count == 1 && !printed { # Only print between the first set of "---"
            if (/^last_update:/) {
                print "last_update:"
                print "  date: " date
                print "  author: " author
                printed=1
                next
            }
        }
        !/^last_update:/ && !/^  date:/ && !/^  author:/ {print} # Skip old last_update lines
    ' "$file" > temp && mv temp "$file"

    # Add the updated file to the staging area
    git add "$file"
done