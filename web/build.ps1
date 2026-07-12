# Build script for the web frontend (Quasar)
# Output goes to ../www/dist (embedded by agentassistant-srv via go:embed)

$ErrorActionPreference = "Stop"

$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path

Push-Location $SCRIPT_DIR
try {
    # Install dependencies if not already installed
    if (-not (Test-Path "$SCRIPT_DIR\node_modules")) {
        Write-Host "Installing web dependencies (pnpm install)..."
        pnpm install
        if ($LASTEXITCODE -ne 0) {
            Write-Host "pnpm install failed!"
            exit 1
        }
    }

    Write-Host "Building web frontend (quasar build)..."
    pnpm run build
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Web build failed!"
        exit 1
    }

    Write-Host "Web build successful! Output in ../www/dist"
} finally {
    Pop-Location
}
