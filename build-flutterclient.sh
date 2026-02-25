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
  echo "请选择构建目标："
  echo "1: linux"
  echo "2: apk"
  echo "3: exit"
  read -r -p "请输入选项（默认 1）: " choice
  case "${choice:-1}" in
    1)
      set -- linux
      ;;
    2)
      set -- apk
      ;;
    3)
      exit 0
      ;;
    *)
      echo "错误: 无效选项: ${choice}"
      exit 2
      ;;
  esac
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
    ;;
  *)
    echo "错误: 不支持的构建目标: $TARGET"
    show_help
    exit 2
    ;;
esac
