#!/bin/bash

# directories
SOURCE_DIR="./Sources"
TESTS_DIR="./Tests"
DEMO_DIR="DemoApplication"

HEADER="//  
//  Copyright © 2024 SparkDI Contributors. All rights reserved.
//

"

add_or_replace_header() {
  local file="$1"
  
  # Delete by default header added by Xcode
  sed -i '' '/^\/\/  Created by/d' "$file"
  sed -i '' '/^\/\/  on/d' "$file"
  
  sed -i '' '/^\/\//d' "$file"
  
  echo -e "$HEADER$(cat "$file")" > "$file"
}

# Iterate over each .swift file in the Sources and Tests directories
for dir in "$SOURCE_DIR" "$TESTS_DIR" "$DEMO_DIR"; do
    if [ -d "$dir" ]; then
      for file in $(find "$dir" -type f -name "*.swift"); do
        add_or_replace_header "$file"
      done
    fi
done
