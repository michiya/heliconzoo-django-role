@echo off

if "%ServiceHostingSDKInstallPath%" == "" (
    echo Can't see the ServiceHostingSDKInstallPath environment variable. Please run from a Windows Azure SDK command-line (run Program Files\Windows Azure SDK\^<version^>\bin\setenv.cmd^).
    GOTO :eof
)

del /s /q *.log *.pyc *.pyo >nul 2>nul

cspack ServiceDefinition.csdef /out:heliconzoo-django-role.cspkg
