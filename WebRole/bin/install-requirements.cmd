@echo off

if not defined PYTHON_INSTALL_DIR set PYTHON_INSTALL_DIR=%SystemDrive%\Python27

REM test installation prerequisites
if not exist %PYTHON_INSTALL_DIR%\python.exe (
echo ERROR: %PYTHON_INSTALL_DIR%\python.exe is missing.
exit /b 1
)

echo Starting installation of requirements...

if not defined LOCAL_RESOURCE_TMP_DIR set LOCAL_RESOURCE_TMP_DIR=%TMP%
if "%LOCAL_RESOURCE_TMP_DIR:~-1%"=="\" set LOCAL_RESOURCE_TMP_DIR=%LOCAL_RESOURCE_TMP_DIR:~0,-1%
echo temporary download directory is set to [%LOCAL_RESOURCE_TMP_DIR%]

%PYTHON_INSTALL_DIR%\python -c "import sys; print sys.version" | find "64 bit"
set PYTHON_X86=%ERRORLEVEL%

:INSTALL_DISTRIBUTE
echo installing distribute...
if exist %PYTHON_INSTALL_DIR%\Scripts\easy_install.exe goto INSTALL_PIP
powershell -c "(new-object System.Net.WebClient).DownloadFile('http://python-distribute.org/distribute_setup.py', '%LOCAL_RESOURCE_TMP_DIR%\distribute_setup.py')
%PYTHON_INSTALL_DIR%\python %LOCAL_RESOURCE_TMP_DIR%\distribute_setup.py

:INSTALL_PIP
echo installing pip...
if exist %PYTHON_INSTALL_DIR%\Scripts\pip.exe goto INSTALL_7ZIP
%PYTHON_INSTALL_DIR%\Scripts\easy_install pip

:INSTALL_7ZIP
echo installing 7-Zip...
set _7ZIP_VERSION=9.20
set _7ZIP_DIR=7za%_7ZIP_VERSION:.=%
if exist %LOCAL_RESOURCE_TMP_DIR%\%_7ZIP_DIR%\7za.exe goto INSTALL_GIT
powershell -c "(new-object System.Net.WebClient).DownloadFile('http://downloads.sourceforge.net/project/sevenzip/7-Zip/%_7ZIP_VERSION%/%_7ZIP_DIR%.zip', '%LOCAL_RESOURCE_TMP_DIR%\%_7ZIP_DIR%.zip')"
%PYTHON_INSTALL_DIR%\python -m zipfile -e %LOCAL_RESOURCE_TMP_DIR%\%_7ZIP_DIR%.zip %LOCAL_RESOURCE_TMP_DIR%\%_7ZIP_DIR%

:INSTALL_GIT
echo installing Git...
where git >nul 2>nul
if %ERRORLEVEL% equ 0 goto INSTALL_PYODBC
set GIT_DIR=PortableGit-1.7.11-preview20120704
powershell -c "(new-object System.Net.WebClient).DownloadFile('http://msysgit.googlecode.com/files/%GIT_DIR%.7z', '%LOCAL_RESOURCE_TMP_DIR%\%GIT_DIR%.7z')"
%LOCAL_RESOURCE_TMP_DIR%\%_7ZIP_DIR%\7za x -o%LOCAL_RESOURCE_TMP_DIR%\%GIT_DIR% -y %LOCAL_RESOURCE_TMP_DIR%\%GIT_DIR%.7z
set PATH=%PATH%;%LOCAL_RESOURCE_TMP_DIR%\%GIT_DIR%\bin

:INSTALL_PYODBC
echo installing pyodbc...
%PYTHON_INSTALL_DIR%\python -c "import pyodbc" 2>nul
if %ERRORLEVEL% equ 0 goto INSTALL_REQUIREMENTS
%SystemDrive%\Python27\Scripts\easy_install -Z pyodbc==3.0.6

:INSTALL_REQUIREMENTS
echo installing required packages...
%SystemDrive%\Python27\Scripts\pip install --timeout=600 --default-timeout=600 -r "%~dp0..\requirements.txt"

echo Finished installation of the requirements.
echo Make sure that you run this command as an administrator if you have any error above.

exit /b
