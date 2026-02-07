#!/bin/bash

# 获取项目根目录
PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
BIN_DIR="$PROJECT_ROOT/bin/win64"

echo "Building all commands for Windows (win64) in cmd/..."
mkdir -p "$BIN_DIR"

# 交叉编译配置
export GOOS=windows
export GOARCH=amd64

# 检测 mingw-w64 编译器
if [[ "$(which x86_64-w64-mingw32-gcc)" == "" ]]; then
    echo "Error: x86_64-w64-mingw32-gcc not found."
    echo "Please install mingw-w64 cross-compilation toolchain."
    echo "On Debian/Ubuntu: sudo apt-get install mingw-w64"
    exit 1
fi

# 遍历 cmd 下的每个子目录
for dir in "$PROJECT_ROOT"/cmd/*; do
    if [ -d "$dir" ]; then
        APP_NAME=$(basename "$dir")
        echo "--------------------------------------------------"
        echo "Building $APP_NAME for Windows..."

        # 根据应用名称设置 CGO
        # agentassistant-input 需要 CGO，mcp 和 srv 不需要
        if [[ "$APP_NAME" == *"input"* ]]; then
            echo "Enabling CGO for $APP_NAME (requires mingw-w64)..."
            export CGO_ENABLED=1
            export CC=x86_64-w64-mingw32-gcc
            export CXX=x86_64-w64-mingw32-g++
        else
            echo "Disabling CGO for $APP_NAME..."
            export CGO_ENABLED=0
            # 清除可能影响交叉编译的 CC/CXX
            unset CC
            unset CXX
        fi

        # 进入目录并编译
        cd "$dir"
        go build -o "$BIN_DIR/$APP_NAME.exe" .

        if [ $? -eq 0 ]; then
            echo "Build successful! Binary location: $BIN_DIR/$APP_NAME.exe"
        else
            echo "Build failed for $APP_NAME!"
            exit 1
        fi
    fi
done

echo "--------------------------------------------------"
echo "All Windows commands built successfully in $BIN_DIR"
