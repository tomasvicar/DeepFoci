@echo off
setlocal EnableDelayedExpansion

REM ────────────────────────────────────────────────────
REM 1) Locate micromamba.exe
REM ────────────────────────────────────────────────────
set "SCRIPT_DIR=%~dp0"
set "ENV_RELATIVE_PATH=..\..\"
set "MMB=%SCRIPT_DIR%..\..\micromamba\micromamba.exe"

if not exist "%MMB%" (
    echo [ERROR] micromamba.exe not found at "%MMB%".
    echo Please run create_micromamba_env.bat first.
    pause
    exit /b 1
)

REM ────────────────────────────────────────────────────
REM 2) Parse environment name from environment.yml
REM ────────────────────────────────────────────────────
for /f "tokens=2 delims=:" %%A in ( 
    'findstr /R /C:"^name:" "%SCRIPT_DIR%environment.yml"' 
) do set "ENVNAME=%%A"
set "ENVNAME=!ENVNAME:~1!"

if "!ENVNAME!"=="" (
    echo [ERROR] Could not parse 'name:' from "%SCRIPT_DIR%environment.yml".
    pause
    exit /b 1
)

REM ────────────────────────────────────────────────────
REM 3) Launch new CMD with the env activated
REM ────────────────────────────────────────────────────
echo Activating environment "!ENVNAME!"...
echo You can install packages with micromamba command (isntead of conda/mamba)
call "%MMB%" shell hook --shell cmd.exe | call
call "%MMB%" run --prefix "%SCRIPT_DIR%%ENV_RELATIVE_PATH%!ENVNAME!" cmd.exe /k



endlocal
