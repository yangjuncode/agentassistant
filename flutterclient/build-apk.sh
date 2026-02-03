#!/bin/bash
# Inject build time into app_config.dart
BUILD_TIME=$(date "+%Y-%m-%d %H:%M:%S")

echo "Starting build with BUILD_TIME=$BUILD_TIME"

if flutter build apk --release --target-platform android-arm64 --split-per-abi --dart-define=BUILD_TIME="$BUILD_TIME"; then
    echo "Build successful."
else
    EXIT_CODE=$?
    echo "--------------------------------------------------------"
    echo "Build failed with exit code $EXIT_CODE"
    echo "Suggestion:"
    echo "If the build failed due to plugin issues, try running:"
    echo ""
    echo "    flutter clean && flutter pub get"
    echo ""
    echo "Then try building again."
    echo "--------------------------------------------------------"
    exit $EXIT_CODE
fi
