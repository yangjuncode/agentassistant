@echo off
setlocal enabledelayedexpansion

set "PROJECT_ROOT=%~dp0"
echo Building all commands in cmd/...

:: 遍历 cmd/ 目录下的每一个子目录
for /d %%d in ("%PROJECT_ROOT%cmd\*") do (
    if exist "%%d\build.bat" (
        echo Running build.bat in %%~nxd...
        call "%%d\build.bat"
        if !ERRORLEVEL! neq 0 (
            echo Build failed for %%~nxd!
            exit /b 1
        )
    )
)

echo All commands built successfully!
