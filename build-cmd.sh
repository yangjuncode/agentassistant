#!/bin/bash

# Get the project root directory
PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

echo "Building all commands in cmd/..."

# Loop through each subdirectory in cmd
for dir in "$PROJECT_ROOT"/cmd/*; do
    if [ -d "$dir" ] && [ -f "$dir/build.sh" ]; then
        echo "Running build.sh in $(basename "$dir")..."
        bash "$dir/build.sh"
        if [ $? -ne 0 ]; then
            echo "Build failed for $(basename "$dir")!"
            exit 1
        fi
    fi
done

echo "All commands built successfully!"
