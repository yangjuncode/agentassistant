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

# 检查 adb 是否可用
if ! command -v adb &> /dev/null; then
    echo "adb not found, skipping install check."
    exit 0
fi

# 检查是否有连接的设备（过滤掉 header 和 offline/unauthorized 设备）
CONNECTED_DEVICES=$(adb devices | awk 'NR>1 && $2=="device" {print $1}')

if [ -z "$CONNECTED_DEVICES" ]; then
    echo "No connected devices found via adb."
    exit 0
fi

echo "--------------------------------------------------------"
echo "Connected device(s):"
echo "$CONNECTED_DEVICES"
echo "--------------------------------------------------------"

# 定位构建产物 APK（split-per-abi 模式下可能有多个）
APK_DIR="build/app/outputs/apk/release"
APK_FILES=$(find "$APK_DIR" -name "*.apk" 2>/dev/null)

if [ -z "$APK_FILES" ]; then
    echo "No APK found in $APK_DIR, skipping install."
    exit 0
fi

# 提示是否安装，默认 Y
read -p "Install APK to connected device? [Y/n] " ANSWER
ANSWER=${ANSWER:-Y}

case "$ANSWER" in
    [yY]*)
        for APK in $APK_FILES; do
            echo "Installing $APK ..."
            adb install -r "$APK"
        done
        echo "Install complete."
        ;;
    *)
        echo "Skipped install."
        ;;
esac
