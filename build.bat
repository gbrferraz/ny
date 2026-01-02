@echo off
taskkill /IM ny.exe /F 2>NUL

rem  CHANGE THIS LINE:
rem  Old: odin build . -debug -out:ny.exe
rem  New:
odin build src -debug -out:ny.exe

if %errorlevel% neq 0 (
    echo Build Failed!
    exit /b %errorlevel%
)
echo Build Complete.
