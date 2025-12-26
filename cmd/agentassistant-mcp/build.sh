#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
BIN_DIR="$PROJECT_ROOT/bin"
APP_NAME=$(basename "$SCRIPT_DIR")

echo "Building $APP_NAME..."
mkdir -p "$BIN_DIR"
cd "$SCRIPT_DIR"
go build -o "$BIN_DIR/$APP_NAME" .

if [ $? -eq 0 ]; then
    echo "Build successful! Binary location: $BIN_DIR/$APP_NAME"
else
    echo "Build failed!"
    exit 1
fi
