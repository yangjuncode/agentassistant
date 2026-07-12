# Build script for agentassistant-mcp (Windows)
# Build output goes to D:\bin

$ErrorActionPreference = "Stop"

# Get the directory where this script is located
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$PROJECT_ROOT = (Resolve-Path "$SCRIPT_DIR\..\..").Path
$BIN_DIR = "D:\bin"
$APP_NAME = Split-Path -Leaf $SCRIPT_DIR

Write-Host "Building $APP_NAME..."
if (-not (Test-Path $BIN_DIR)) {
    New-Item -ItemType Directory -Path $BIN_DIR | Out-Null
}

Push-Location $SCRIPT_DIR
try {
    go build -o "$BIN_DIR\$APP_NAME.exe" .
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Build successful! Binary location: $BIN_DIR\$APP_NAME.exe"
    } else {
        Write-Host "Build failed!"
        exit 1
    }
} finally {
    Pop-Location
}
