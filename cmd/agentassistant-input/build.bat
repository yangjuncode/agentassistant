@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
:: 获取项目根目录 (上两级)
pushd "%SCRIPT_DIR%..\.."
set "PROJECT_ROOT=%CD%"
popd
set "BIN_DIR=%PROJECT_ROOT%\bin"

:: 获取当前文件夹名称作为程序名
for %%i in ("%~dp0.") do set "APP_NAME=%%~nxi"

echo Building %APP_NAME%...
if not exist "%BIN_DIR%" mkdir "%BIN_DIR%"
cd /d "%SCRIPT_DIR%"
go build -o "%BIN_DIR%\%APP_NAME%.exe" .

if %ERRORLEVEL% equ 0 (
    echo Build successful! Binary location: %BIN_DIR%\%APP_NAME%.exe
) else (
    echo Build failed!
    exit /b 1
)
