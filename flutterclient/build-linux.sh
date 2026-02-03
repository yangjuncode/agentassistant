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

# Inject build time into app_config.dart
BUILD_TIME=$(date "+%Y-%m-%d %H:%M:%S")

if flutter build linux --release --dart-define=BUILD_TIME="$BUILD_TIME"; then
    # Copy build output to root bin directory
    echo "Build successful. Copying build output to ../bin..."
    mkdir -p ../bin
    cp -rv build/linux/x64/release/bundle/* ../bin/
    echo "Build and export to bin/ complete!"
else
    EXIT_CODE=$?
    echo "--------------------------------------------------------"
    echo "Error: Flutter build failed with exit code $EXIT_CODE. Output was not copied."
    echo "Suggestion:"
    echo "If the build failed due to plugin issues, try running:"
    echo ""
    echo "    flutter clean && flutter pub get"
    echo ""
    echo "Then try building again."
    echo "--------------------------------------------------------"
    exit $EXIT_CODE
fi