#!/bin/bash
# Inject build time into app_config.dart
BUILD_TIME=$(date "+%Y-%m-%d %H:%M:%S")
sed -i "s/static const String buildTime = '.*';/static const String buildTime = '$BUILD_TIME';/" lib/config/app_config.dart
 
flutter build apk --release --target-platform android-arm64 --split-per-abi
