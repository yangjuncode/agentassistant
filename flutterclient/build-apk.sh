#!/bin/bash
# Inject build time into app_config.dart
BUILD_TIME=$(date "+%Y-%m-%d %H:%M:%S")
 
flutter build apk --release --target-platform android-arm64 --split-per-abi --dart-define=BUILD_TIME="$BUILD_TIME"
