@echo off

echo Starting installation of requirements...

REM Helicon Zoo requires Python to be there
set PYTHON_INSTALL_DIR=%SystemDrive%\Python27

REM test installation prerequisites
if not exist %PYTHON_INSTALL_DIR%\python.exe (
echo ERROR: %PYTHON_INSTALL_DIR%\python.exe is missing.
exit /b 1
)
if not exist %SystemDrive%\Zoo (
echo ERROR: %SystemDrive%\Zoo is missing.
exit /b 1
)

if "%LOCAL_RESOURCE_TMP_DIR%"=="" set LOCAL_RESOURCE_TMP_DIR=%TMP%
if "%LOCAL_RESOURCE_TMP_DIR:~-1%"=="\" set LOCAL_RESOURCE_TMP_DIR=%LOCAL_RESOURCE_TMP_DIR:~0,-1%
echo temporary download directory is set to [%LOCAL_RESOURCE_TMP_DIR%]

%PYTHON_INSTALL_DIR%\python -c "import sys; print sys.version" | find "64 bit"
set PYTHON_X86=%ERRORLEVEL%

cd /d "%~dp0"


REM install package managers
:INSTALL_SETUPTOOLS
echo installing setuptools...
if exist %PYTHON_INSTALL_DIR%\Scripts\easy_install.exe goto INSTALL_PIP
powershell -c "(new-object System.Net.WebClient).DownloadFile('http://peak.telecommunity.com/dist/ez_setup.py', '%LOCAL_RESOURCE_TMP_DIR%\easy_setup.py')"
%PYTHON_INSTALL_DIR%\python %LOCAL_RESOURCE_TMP_DIR%\easy_setup.py

:INSTALL_PIP
echo installing pip...
if exist %PYTHON_INSTALL_DIR%\Scripts\pip.exe goto INSTALL_PYODBC
%PYTHON_INSTALL_DIR%\Scripts\easy_install pip


REM install django-pyodbc
:INSTALL_PYODBC
echo installing pyodbc...
%PYTHON_INSTALL_DIR%\python -c "import pyodbc" 2>nul
if "%ERRORLEVEL%"=="0" goto INSTALL_DJANGO_PYODBC
if "%PYTHON_X86%"=="0" goto INSTALL_PYODBC_X64
%SystemDrive%\Python27\Scripts\easy_install -Z pyodbc==3.0.5
goto INSTALL_DJANGO_PYODBC

:INSTALL_PYODBC_X64
set PYODBC_X64_INSTALLER=pyodbc-3.0.2.win-amd64-py2.7.exe
powershell -c "(new-object System.Net.WebClient).DownloadFile('http://pyodbc.googlecode.com/files/%PYODBC_X64_INSTALLER%', '%LOCAL_RESOURCE_TMP_DIR%\%PYODBC_X64_INSTALLER%')"
%SystemDrive%\Zoo\Tools\7za x -o%LOCAL_RESOURCE_TMP_DIR%\pyodbc -y %LOCAL_RESOURCE_TMP_DIR%\%PYODBC_X64_INSTALLER%
xcopy /e /h /y %LOCAL_RESOURCE_TMP_DIR%\pyodbc\PLATLIB\* %PYTHON_INSTALL_DIR%\Lib\site-packages

:INSTALL_DJANGO_PYODBC
echo installing django-pyodbc...
%PYTHON_INSTALL_DIR%\python -c "import sql_server.pyodbc" 2>nul
if "%ERRORLEVEL%"=="0" goto INSTALL_REQUIREMENTS
set DJANGO_PYODBC_EXTRACT_DIR=%LOCAL_RESOURCE_TMP_DIR%\django-pyodbc
powershell -c "(new-object System.Net.WebClient).DownloadFile('https://github.com/avidal/django-pyodbc/zipball/django-1.4', '%LOCAL_RESOURCE_TMP_DIR%\django-pyodbc.zip')"
%SystemDrive%\Zoo\Tools\7za x -o%DJANGO_PYODBC_EXTRACT_DIR% -y %LOCAL_RESOURCE_TMP_DIR%\django-pyodbc.zip
for /f "usebackq" %%i IN (`dir /b %DJANGO_PYODBC_EXTRACT_DIR%`) do ren %DJANGO_PYODBC_EXTRACT_DIR%\%%i django-pyodbc
cd /d %DJANGO_PYODBC_EXTRACT_DIR%\django-pyodbc
%PYTHON_INSTALL_DIR%\python setup.py install
cd /d "%~dp0"


REM install other required python packages
:INSTALL_REQUIREMENTS
echo installing required packages...
%SystemDrive%\Python27\Scripts\pip install --timeout=600 --default-timeout=600 -r ..\requirements.txt


echo Finished installation of the requirements.
echo Make sure that you run this command as an administrator if you have any error above.
