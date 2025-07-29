@echo off
setlocal EnableDelayedExpansion

REM 1) Define paths
set "SCRIPT_DIR=%~dp0"
set "MICROMAMBAPATH=%SCRIPT_DIR%..\..\micromamba"
set "ENV_FILE=%SCRIPT_DIR%environment.yml"
set "ENV_RELATIVE_PATH=..\..\"

REM 2) Detect architecture
if /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
  set "PLATFORM=win-64"
  set "MMB_URL=https://github.com/mamba-org/micromamba-releases/releases/latest/download/micromamba-win-64.exe"
) else if /I "%PROCESSOR_ARCHITECTURE%"=="ARM64" (
  set "PLATFORM=win-arm64"
  set "MMB_URL=https://github.com/mamba-org/micromamba-releases/releases/latest/download/micromamba-win-arm64.exe"
) else (
  echo [ERROR] Unsupported architecture: %PROCESSOR_ARCHITECTURE%
  pause
  exit /b 1
)

REM 3) Download micromamba.exe if missing
if not exist "%MICROMAMBAPATH%\micromamba.exe" (
  mkdir "%MICROMAMBAPATH%" 2>nul

  echo [1/3] Downloading micromamba executable for %PLATFORM%...
  powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "Invoke-WebRequest -Uri '%MMB_URL%' -OutFile '%MICROMAMBAPATH%\micromamba.exe' -UseBasicParsing"
  if errorlevel 1 (
    echo [ERROR] Download failed.
    pause
    exit /b 1
  )
)

set "MMB=%MICROMAMBAPATH%\micromamba.exe"

REM 4) Parse the environment name
for /f "tokens=2 delims=:" %%A in (
  'findstr /R /C:"^name:" "%ENV_FILE%"'
) do set "ENVNAME=%%A"
set "ENVNAME=!ENVNAME:~1!"
if "!ENVNAME!"=="" (
  echo [ERROR] Could not parse 'name:' from %ENV_FILE%.
  pause
  exit /b 1
)

echo [2/3] Creating environment "!ENVNAME!"...
"%MMB%" create --root-prefix "%MICROMAMBAPATH%" --prefix "%SCRIPT_DIR%%ENV_RELATIVE_PATH%!ENVNAME!" --file "%ENV_FILE%" --yes

if errorlevel 1 (
  echo [ERROR] Environment creation failed.
  pause
  exit /b 1
)

REM 6) Launch a new window with the env active
echo [3/3] Launching new shell with "!ENVNAME!" activated...
echo You can install packages with micromamba command (isntead of conda/mamba)
call "%MMB%" shell hook --shell cmd.exe | call
call "%MMB%" run --prefix "%SCRIPT_DIR%%ENV_RELATIVE_PATH%!ENVNAME!" cmd.exe /k

call "C:\\Users\\tomas\\AppData\\Roaming\\mamba\\condabin\\mamba_hook.bat"

