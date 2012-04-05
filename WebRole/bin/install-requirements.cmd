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
if exist %PYTHON_INSTALL_DIR%\Scripts\pip.exe goto INSTALL_SVN
%PYTHON_INSTALL_DIR%\Scripts\easy_install pip


REM install django-pyodbc
:INSTALL_SVN
echo installing subversion...
set SVN_VERSION=1.7.4
set SVN_DIR=svn-win32-%SVN_VERSION%
set SVN_INSTALLER=%SVN_DIR%.zip
if exist %LOCAL_RESOURCE_TMP_DIR%\%SVN_DIR%\bin\svn.exe goto INSTALL_PYODBC
powershell -c "(new-object System.Net.WebClient).DownloadFile('http://downloads.sourceforge.net/project/win32svn/%SVN_VERSION%/%SVN_INSTALLER%', '%LOCAL_RESOURCE_TMP_DIR%\%SVN_INSTALLER%')"
%SystemDrive%\Zoo\Tools\7za x -o%LOCAL_RESOURCE_TMP_DIR% -y %LOCAL_RESOURCE_TMP_DIR%\%SVN_INSTALLER%

:INSTALL_PYODBC
echo installing pyodbc...
%PYTHON_INSTALL_DIR%\python -c "import pyodbc" 2>nul
if "%ERRORLEVEL%"=="0" goto INSTALL_DJANGO_PYODBC
if "%PYTHON_X86%"=="0" goto INSTALL_PYODBC_X64
%SystemDrive%\Python27\Scripts\easy_install -Z pyodbc==3.0.2
goto INSTALL_DJANGO_PYODBC

:INSTALL_PYODBC_X64
set PYODBC_X64_INSTALLER=pyodbc-3.0.2.win-amd64-py2.7.exe
powershell -c "(new-object System.Net.WebClient).DownloadFile('http://pyodbc.googlecode.com/files/%PYODBC_X64_INSTALLER%', '%LOCAL_RESOURCE_TMP_DIR%\%PYODBC_X64_INSTALLER%')"
%SystemDrive%\Zoo\Tools\7za x -o%LOCAL_RESOURCE_TMP_DIR%\pyodbc -y %LOCAL_RESOURCE_TMP_DIR%\%PYODBC_X64_INSTALLER%
xcopy /e /h /y %LOCAL_RESOURCE_TMP_DIR%\pyodbc\PLATLIB\* %PYTHON_INSTALL_DIR%\Lib\site-packages

:INSTALL_DJANGO_PYODBC
echo installing django-pyodbc...
%PYTHON_INSTALL_DIR%\python -c "import sql_server.pyodbc" 2>nul
if "%ERRORLEVEL%"=="0" goto INSTALL_HG
cd /d %LOCAL_RESOURCE_TMP_DIR%
%LOCAL_RESOURCE_TMP_DIR%\%SVN_DIR%\bin\svn export http://django-pyodbc.googlecode.com/svn/trunk/ django-pyodbc
cd .\django-pyodbc
%PYTHON_INSTALL_DIR%\python setup.py install
cd /d "%~dp0"


REM install django-mssql
:INSTALL_HG
echo installing mercurial...
if exist "%ProgramFiles%\Mercurial\hg.exe" goto INSTALL_PYWIN32
set HG_INSTALLER=Mercurial-2.1.2-x86.exe
if exist "%ProgramFiles(x86)%" set HG_INSTALLER=Mercurial-2.1.2-x64.exe
powershell -c "(new-object System.Net.WebClient).DownloadFile('http://mercurial.selenic.com/release/windows/%HG_INSTALLER%', '%LOCAL_RESOURCE_TMP_DIR%\%HG_INSTALLER%')"
%LOCAL_RESOURCE_TMP_DIR%\%HG_INSTALLER% /verysilent /sp-
set PATH=%PATH%;%ProgramFiles%\Mercurial

:INSTALL_PYWIN32
echo installing pywin32...
%PYTHON_INSTALL_DIR%\python -c "import win32com" 2>nul
if "%ERRORLEVEL%"=="0" goto INSTALL_DJANGO_MSSQL
set PYWIN32_INSTALLER=pywin32-217.win32-py2.7.exe
if "%PYTHON_X86%"=="0" set PYWIN32_INSTALLER=pywin32-217.win-amd64-py2.7.exe
powershell -c "(new-object System.Net.WebClient).DownloadFile('http://downloads.sourceforge.net/project/pywin32/pywin32/Build 217/%PYWIN32_INSTALLER%', '%LOCAL_RESOURCE_TMP_DIR%\%PYWIN32_INSTALLER%')"
%SystemDrive%\Zoo\Tools\7za x -o%LOCAL_RESOURCE_TMP_DIR%\pywin32 -y %LOCAL_RESOURCE_TMP_DIR%\%PYWIN32_INSTALLER%
xcopy /e /h /y %LOCAL_RESOURCE_TMP_DIR%\pywin32\PLATLIB\* %PYTHON_INSTALL_DIR%\Lib\site-packages
copy %LOCAL_RESOURCE_TMP_DIR%\pywin32\SCRIPTS\* %PYTHON_INSTALL_DIR%\Scripts\
%PYTHON_INSTALL_DIR%\python %PYTHON_INSTALL_DIR%\Scripts\pywin32_postinstall.py -install

:INSTALL_DJANGO_MSSQL
echo installing django-mssql...
%PYTHON_INSTALL_DIR%\python -c "import sqlserver_ado" 2>nul
if "%ERRORLEVEL%"=="0" goto INSTALL_REQUIREMENTS
%SystemDrive%\Python27\Scripts\pip install hg+https://django-mssql.googlecode.com/hg/#egg=django-mssql


REM install other required python packages
:INSTALL_REQUIREMENTS
echo installing required packages...
%SystemDrive%\Python27\Scripts\pip install --timeout=600 --default-timeout=600 -r ..\requirements.txt


echo Finished installation of the requirements.
echo Make sure that you run this command as an administrator if you have any error above.
