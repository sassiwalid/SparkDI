#!/bin/bash

# Define the header
HEADER="//\n//  Copyright © 2024 SparkDI Contributors. All rights reserved.\n//"

# Iterate over each .swift file in the Sources and Tests directories
for file in $(find Sources Tests -name "*.swift"); do
    # Check if the header is already present
    if ! grep -q "SparkDI Contributors" "$file"; then
        # Add the header at the beginning of the file
        echo -e "$HEADER\n$(cat "$file")" > "$file"
        echo "Added header to $file"
    else
        echo "Header already present in $file"
    fi
done
