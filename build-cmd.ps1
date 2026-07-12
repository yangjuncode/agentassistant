# Build all commands in cmd/ (Windows)
# Build output goes to D:\bin

$ErrorActionPreference = "Stop"

# Get the project root directory
$PROJECT_ROOT = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "Building all commands in cmd/..."

# Loop through each subdirectory in cmd
Get-ChildItem -Path "$PROJECT_ROOT\cmd" -Directory | ForEach-Object {
    $dir = $_.FullName
    $buildScript = Join-Path $dir "build.ps1"
    if (Test-Path $buildScript) {
        Write-Host "Running build.ps1 in $($_.Name)..."
        & powershell -NoProfile -ExecutionPolicy Bypass -File $buildScript
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Build failed for $($_.Name)!"
            exit 1
        }
    }
}

Write-Host "All commands built successfully!"
