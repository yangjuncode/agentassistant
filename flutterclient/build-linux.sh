#!/bin/bash

# Check if icon exists, if not create it from Android icon
ICON_FILE="linux/agent-assistant-icon.png"
ANDROID_ICON="android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png"

if [ ! -f "$ICON_FILE" ]; then
    echo "Icon not found, creating from Android icon..."
    if [ -f "$ANDROID_ICON" ]; then
        if command -v convert &> /dev/null; then
            convert "$ANDROID_ICON" -resize 128x128 "$ICON_FILE"
            echo "Icon created: $ICON_FILE"
        else
            echo "Warning: ImageMagick 'convert' not found. Copying icon as-is..."
            cp "$ANDROID_ICON" "$ICON_FILE"
        fi
    else
        echo "Error: Android icon not found at $ANDROID_ICON"
        exit 1
    fi
else
    echo "Icon already exists: $ICON_FILE"
fi

flutter build linux --release

# Copy build output to root bin directory
echo "Copying build output to ../bin..."
mkdir -p ../bin
cp -rv build/linux/x64/release/bundle/* ../bin/
echo "Build and export to bin/ complete!"