#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

show_help() {
  echo "用法: ./build-flutterclient.sh <linux|apk> [--clean]"
  echo "  linux    构建 Flutter 桌面 Linux release（产物由 flutterclient/build-linux.sh 复制到根目录 bin/）"
  echo "  apk      构建 Android APK release（调用 flutterclient/build-apk.sh）"
  echo "  --clean  构建前先执行 flutter clean && flutter pub get"
}

PRE_CLEAN="false"
if [[ "${1:-}" == "--clean" ]]; then
  PRE_CLEAN="true"
  shift || true
fi

if [[ "${1:-}" == "-h" ]] || [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "help" ]]; then
  show_help
  exit 0
fi

if [[ "${1:-}" == "" ]]; then
  echo "未提供构建参数，将执行默认动作：构建 linux，如果需要构建 apk，请执行 ./build-flutterclient.sh apk"
  set -- linux
fi

TARGET="$1"
shift || true

DO_CLEAN="$PRE_CLEAN"
ARGS=()
for arg in "$@"; do
  if [[ "$arg" == "--clean" ]]; then
    DO_CLEAN="true"
  else
    ARGS+=("$arg")
  fi
done

FLUTTER_DIR="$PROJECT_ROOT/flutterclient"
if [[ ! -d "$FLUTTER_DIR" ]]; then
  echo "错误: 未找到目录 $FLUTTER_DIR"
  exit 1
fi

run_in_flutter_dir() {
  (
    cd "$FLUTTER_DIR"
    if [[ "$DO_CLEAN" == "true" ]]; then
      flutter clean
      flutter pub get
    fi
    "$@"
  )
}

case "$TARGET" in
  linux)
    run_in_flutter_dir bash ./build-linux.sh "${ARGS[@]}"
    ;;
  apk)
    run_in_flutter_dir bash ./build-apk.sh "${ARGS[@]}"
    
    # Check if adb is installed and there are devices connected
    if command -v adb &> /dev/null; then
      # Check if any device is connected and in 'device' state (excluding headers)
      devices=$(adb devices | grep -v "List of devices" | grep -w "device" || true)
      if [[ -n "$devices" ]]; then
        echo -e "\n============================================="
        echo "检测到已连接的 adb 设备:"
        echo "$devices"
        echo "============================================="
        
        # Find the built APK
        APK_PATH=""
        if [[ -f "$FLUTTER_DIR/build/app/outputs/flutter-apk/app-arm64-v8a-release.apk" ]]; then
          APK_PATH="$FLUTTER_DIR/build/app/outputs/flutter-apk/app-arm64-v8a-release.apk"
        elif [[ -f "$FLUTTER_DIR/build/app/outputs/flutter-apk/app-release.apk" ]]; then
          APK_PATH="$FLUTTER_DIR/build/app/outputs/flutter-apk/app-release.apk"
        else
          # Fallback to finding any release APK in the outputs directory
          APK_PATH=$(find "$FLUTTER_DIR/build/app/outputs/flutter-apk" -name "*release.apk" -type f | head -n 1 || true)
        fi
        
        if [[ -n "$APK_PATH" ]] && [[ -f "$APK_PATH" ]]; then
          # Prompt for installation
          install_confirm="y"
          read -p "是否要将生成的 APK 安装到设备上? [Y/n]: " install_confirm < /dev/tty || install_confirm="y"
          if [[ -z "$install_confirm" ]] || [[ "$install_confirm" =~ ^[Yy]$ ]]; then
            echo "正在安装 $APK_PATH ..."
            adb install -r "$APK_PATH"
            echo "安装完成！"
          else
            echo "已跳过安装。"
          fi
        else
          echo "警告: 未能找到生成的 APK 文件，无法进行 adb 安装。"
        fi
      fi
    fi
    ;;
  *)
    echo "错误: 不支持构建目标: $TARGET"
    show_help
    exit 2
    ;;
esac
