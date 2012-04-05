@echo off

echo Starting installation...

if "%1"=="amd64" set PYTHON_ARCH=.%1

REM Helicon Zoo requires Python to be there
set PYTHON_INSTALL_DIR=%SystemDrive%\Python27

if "%LOCAL_RESOURCE_TMP_DIR%"=="" set LOCAL_RESOURCE_TMP_DIR=%TMP%
if "%LOCAL_RESOURCE_TMP_DIR:~-1%"=="\" set LOCAL_RESOURCE_TMP_DIR=%LOCAL_RESOURCE_TMP_DIR:~0,-1%

cd /d "%~dp0"

md "%~dp0appdata"
reg add "hku\.default\software\microsoft\windows\currentversion\explorer\user shell folders" /v "Local AppData" /t REG_EXPAND_SZ /d "%~dp0appdata" /f

echo installing Python...
set PYTHON_VERSION=2.7.2
set PYTHON_INSTALLER=python-%PYTHON_VERSION%%PYTHON_ARCH%.msi
powershell -c "(new-object System.Net.WebClient).DownloadFile('http://www.python.org/ftp/python/%PYTHON_VERSION%/%PYTHON_INSTALLER%', '%LOCAL_RESOURCE_TMP_DIR%\%PYTHON_INSTALLER%')"
msiexec /i %LOCAL_RESOURCE_TMP_DIR%\%PYTHON_INSTALLER% /qn TARGET_DIR=%PYTHON_INSTALL_DIR%

echo installing WebPICmdLine...
set WEBPI_DIR=webpicmdline_anycpu
set WEBPI_INSTALLER=%WEBPI_DIR%.zip
powershell -c "(new-object System.Net.WebClient).DownloadFile('http://www.iis.net/community/files/webpi/%WEBPI_INSTALLER%', '%LOCAL_RESOURCE_TMP_DIR%\%WEBPI_INSTALLER%')"
%PYTHON_INSTALL_DIR%\python -m zipfile -e %LOCAL_RESOURCE_TMP_DIR%\%WEBPI_INSTALLER% %LOCAL_RESOURCE_TMP_DIR%\%WEBPI_DIR%

echo installing Helicon Zoo...
%LOCAL_RESOURCE_TMP_DIR%\%WEBPI_DIR%\webpicmdline /Products:HeliconZooModule /Feeds:http://www.helicontech.com/zoo/feed/ /AcceptEula

call "%~dp0"install-requirements

REM allow write access to Python runtime for bytecode optimization by Helicon Zoo
icacls %PYTHON_INSTALL_DIR% /grant "Everyone":F /T

reg add "hku\.default\software\microsoft\windows\currentversion\explorer\user shell folders" /v "Local AppData" /t REG_EXPAND_SZ /d %%USERPROFILE%%\AppData\Local /f

echo Completed installation.
