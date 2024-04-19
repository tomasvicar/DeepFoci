@echo off

set MAMBAPATH="C:\ProgramData\miniforge3"
if not exist "%MAMBAPATH%\" (
    echo Error: Directory %MAMBAPATH% does not exist.
    exit /b 1
)

for /f "tokens=2 delims=:" %%a in ('findstr /r "^name:" environment.yml') do set ENVNAME=%%a
set ENVNAME=%ENVNAME:~1%
call %MAMBAPATH%\Scripts\activate.bat
start cmd /k mamba activate "..\..\%ENVNAME%"
