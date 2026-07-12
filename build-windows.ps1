# Build all Windows binaries (web + cmd + flutter client)
# Build output goes to D:\bin

$ErrorActionPreference = "Stop"

# Get the project root directory
$PROJECT_ROOT = Split-Path -Parent $MyInvocation.MyCommand.Path
$BIN_DIR = "D:\bin"

if (-not (Test-Path $BIN_DIR)) {
    New-Item -ItemType Directory -Path $BIN_DIR | Out-Null
}

# --- Build web frontend (needed by agentassistant-srv via go:embed) ---
Write-Host "===== Building web frontend ====="
& powershell -NoProfile -ExecutionPolicy Bypass -File "$PROJECT_ROOT\web\build.ps1"
if ($LASTEXITCODE -ne 0) {
    Write-Host "Web build failed!"
    exit 1
}

# --- Build Go cmd binaries ---
Write-Host ""
Write-Host "===== Building Go cmd binaries ====="
& powershell -NoProfile -ExecutionPolicy Bypass -File "$PROJECT_ROOT\build-cmd.ps1"
if ($LASTEXITCODE -ne 0) {
    Write-Host "cmd build failed!"
    exit 1
}

# --- Build Flutter Windows client ---
Write-Host ""
Write-Host "===== Building Flutter Windows client ====="
& powershell -NoProfile -ExecutionPolicy Bypass -File "$PROJECT_ROOT\flutterclient\build-windows.ps1"
if ($LASTEXITCODE -ne 0) {
    Write-Host "Flutter build failed!"
    exit 1
}

Write-Host ""
Write-Host "All Windows builds complete! Output in $BIN_DIR"
Write-Host "  - agentassistant-srv.exe"
Write-Host "  - agentassistant-mcp.exe"
Write-Host "  - agentassistant-input.exe"
Write-Host "  - agentassistant-flutter.exe (plus dlls/data)"
