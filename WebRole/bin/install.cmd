@echo off

echo Starting installation...

if not "%1"=="" set PYTHON_ARCH=.%1

REM Helicon Zoo requires Python to be there
set PYTHON_INSTALL_DIR=%SystemDrive%\Python27

if "%LOCAL_RESOURCE_TMP_DIR%"=="" set LOCAL_RESOURCE_TMP_DIR=%TMP%\

cd /d "%~dp0"

md "%~dp0appdata"
reg add "hku\.default\software\microsoft\windows\currentversion\explorer\user shell folders" /v "Local AppData" /t REG_EXPAND_SZ /d "%~dp0appdata" /f

echo installing Python...
powershell -c "(new-object System.Net.WebClient).DownloadFile('http://www.python.org/ftp/python/2.7.2/python-2.7.2%PYTHON_ARCH%.msi', '%LOCAL_RESOURCE_TMP_DIR%python27.msi')"
msiexec /i %LOCAL_RESOURCE_TMP_DIR%python27.msi /qn TARGET_DIR=%PYTHON_INSTALL_DIR%

echo installing WebPICmdLine...
REM tentative fix (the download site seems to be down as of 2012/03/13)
REM powershell -c "(new-object System.Net.WebClient).DownloadFile('http://www.iis.net/community/files/webpi/webpicmdline_anycpu.zip', '%LOCAL_RESOURCE_TMP_DIR%webpicmdline.zip')"
copy %~dp0webpicmdline_anycpu.zip %LOCAL_RESOURCE_TMP_DIR%webpicmdline.zip
%PYTHON_INSTALL_DIR%\python -m zipfile -e %LOCAL_RESOURCE_TMP_DIR%webpicmdline.zip %LOCAL_RESOURCE_TMP_DIR%webpicmdline

echo installing Helicon Zoo...
%LOCAL_RESOURCE_TMP_DIR%webpicmdline\webpicmdline /Products:HeliconZooModule /Feeds:http://www.helicontech.com/zoo/feed/ /AcceptEula

call "%~dp0"install-requirements

REM allow write access to Python runtime for bytecode optimization by Helicon Zoo
icacls %PYTHON_INSTALL_DIR% /grant "Everyone":F /T

reg add "hku\.default\software\microsoft\windows\currentversion\explorer\user shell folders" /v "Local AppData" /t REG_EXPAND_SZ /d %%USERPROFILE%%\AppData\Local /f

echo Completed installation.
