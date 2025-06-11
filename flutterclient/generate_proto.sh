#!/bin/bash

# Generate Dart protobuf files for Flutter client
# This script generates Dart protobuf files from the proto definitions

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Generating Dart protobuf files...${NC}"

# Check if protoc is installed
if ! command -v protoc &> /dev/null; then
    echo -e "${RED}Error: protoc is not installed. Please install Protocol Buffers compiler.${NC}"
    echo "On macOS: brew install protobuf"
    echo "On Ubuntu: sudo apt-get install protobuf-compiler"
    exit 1
fi

# Check if protoc-gen-dart is installed
if ! command -v protoc-gen-dart &> /dev/null; then
    echo -e "${YELLOW}protoc-gen-dart not found. Installing...${NC}"
    dart pub global activate protoc_plugin
    export PATH="$PATH:$HOME/.pub-cache/bin"
fi

# Create output directory
mkdir -p lib/proto

# Generate Dart files from proto
echo -e "${GREEN}Generating protobuf files...${NC}"
protoc \
    --proto_path=../proto \
    --dart_out=lib/proto \
    ../proto/agentassist.proto

echo -e "${GREEN}Protobuf generation completed successfully!${NC}"
echo -e "${YELLOW}Generated files:${NC}"
ls -la lib/proto/

echo -e "${GREEN}Don't forget to run 'flutter pub get' to install dependencies.${NC}"
