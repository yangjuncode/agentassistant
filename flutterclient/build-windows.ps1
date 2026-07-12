# Build script for Agent Assistant Flutter Windows application
# Build output goes to D:\bin

$ErrorActionPreference = "Stop"

# Get the directory where this script is located
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$BIN_DIR = "D:\bin"

# Inject build time into app_config.dart via dart-define
$BUILD_TIME = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

Push-Location $SCRIPT_DIR
try {
    Write-Host "Building Flutter Windows release..."
    flutter build windows --release --dart-define="BUILD_TIME=$BUILD_TIME"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Flutter build failed. Output was not copied."
        exit 1
    }

    # Build output location
    $BUNDLE_DIR = Join-Path $SCRIPT_DIR "build\windows\x64\runner\Release"
    if (-not (Test-Path $BUNDLE_DIR)) {
        Write-Host "Error: Build output not found at $BUNDLE_DIR"
        exit 1
    }

    # Copy build output to D:\bin\flutterclient (keep dlls/data alongside the exe)
    $FLUTTER_BIN_DIR = Join-Path $BIN_DIR "flutterclient"
    if (-not (Test-Path $BIN_DIR)) {
        New-Item -ItemType Directory -Path $BIN_DIR | Out-Null
    }
    if (Test-Path $FLUTTER_BIN_DIR) {
        Remove-Item -Path $FLUTTER_BIN_DIR -Recurse -Force
    }
    New-Item -ItemType Directory -Path $FLUTTER_BIN_DIR | Out-Null

    Write-Host "Build successful. Copying build output to $FLUTTER_BIN_DIR..."
    Copy-Item -Path "$BUNDLE_DIR\*" -Destination $FLUTTER_BIN_DIR -Recurse -Force
    Write-Host "Build and export to $FLUTTER_BIN_DIR complete!"
} finally {
    Pop-Location
}
