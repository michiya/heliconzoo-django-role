@echo off

cd "%~dp0"

icacls %RoleRoot%\approot /grant "Everyone":F /T

REM This script will only execute on production Windows Azure.
if "%EMULATED%"=="true" goto :EOF

REM run the command like this if you want to you use Python x64 instead
REM install.cmd amd64 >..\startup-tasks.log 2>..\startup-tasks-error.log
install.cmd >..\startup-tasks.log 2>..\startup-tasks-error.log
