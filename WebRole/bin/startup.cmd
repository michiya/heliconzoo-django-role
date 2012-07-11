@echo off

icacls %RoleRoot%\approot /grant "Everyone":F /T

REM the installer script will only be executed on production Windows Azure.
if "%EMULATED%"=="true" goto :EOF

REM run the command like this if you want to you use Python x64 instead
REM call install.cmd amd64 >..\startup-tasks.log 2>..\startup-tasks-error.log
call install.cmd >..\startup-tasks.log 2>..\startup-tasks-error.log
