@echo off
setlocal

:: --- Configuration ---
set "EXE_NAME=ny.exe"
set "SRC_DIR=src"
set "BUILD_DIR=build"
:: ---------------------

echo [1/2] Creating build directory...
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"

echo [2/2] Compiling Odin for Release...
odin build %SRC_DIR% -out:%BUILD_DIR%\%EXE_NAME% -o:speed -subsystem:windows

:: Check if the build failed
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERROR] Build Failed!
    exit /b %ERRORLEVEL%
)

echo.
echo ---------------------------------------
echo  SUCCESS! Build is ready in: \%BUILD_DIR%
echo ---------------------------------------
endlocal
pause
