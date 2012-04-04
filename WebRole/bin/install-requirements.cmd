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

if "%LOCAL_RESOURCE_TMP_DIR%"=="" set LOCAL_RESOURCE_TMP_DIR=%TMP%\
echo temporary download directory is set to [%LOCAL_RESOURCE_TMP_DIR%]

%PYTHON_INSTALL_DIR%\python -c "import sys; print sys.version" | find "64 bit"
set PYTHON_X86=%ERRORLEVEL%

cd /d "%~dp0"


REM install package managers
:INSTALL_SETUPTOOLS
echo installing setuptools...
if exist %PYTHON_INSTALL_DIR%\Scripts\easy_install.exe goto INSTALL_PIP
powershell -c "(new-object System.Net.WebClient).DownloadFile('http://peak.telecommunity.com/dist/ez_setup.py', '%LOCAL_RESOURCE_TMP_DIR%easy_setup.py')"
%PYTHON_INSTALL_DIR%\python %LOCAL_RESOURCE_TMP_DIR%easy_setup.py

:INSTALL_PIP
echo installing pip...
if exist %PYTHON_INSTALL_DIR%\Scripts\pip.exe goto INSTALL_SUBVERSION
%PYTHON_INSTALL_DIR%\Scripts\easy_install pip


REM install django-pyodbc
:INSTALL_SUBVERSION
echo installing subversion...
if exist %LOCAL_RESOURCE_TMP_DIR%svn-win32\bin\svn.exe goto INSTALL_PYODBC
powershell -c "(new-object System.Net.WebClient).DownloadFile('http://downloads.sourceforge.net/project/win32svn/1.7.2/svn-win32-1.7.2.zip', '%LOCAL_RESOURCE_TMP_DIR%svn-win32-1.7.2.zip')"
%SystemDrive%\Zoo\Tools\7za x -o%LOCAL_RESOURCE_TMP_DIR% -y %LOCAL_RESOURCE_TMP_DIR%svn-win32-1.7.2.zip
ren %LOCAL_RESOURCE_TMP_DIR%svn-win32-1.7.2 svn-win32

:INSTALL_PYODBC
echo installing pyodbc...
%PYTHON_INSTALL_DIR%\python -c "import pyodbc" 2>nul
if "%ERRORLEVEL%"=="0" goto INSTALL_DJANGO_PYODBC
if "%PYTHON_X86%"=="0" goto INSTALL_PYODBC_X64
%SystemDrive%\Python27\Scripts\easy_install -Z pyodbc==3.0.2
goto INSTALL_DJANGO_PYODBC

:INSTALL_PYODBC_X64
powershell -c "(new-object System.Net.WebClient).DownloadFile('http://pyodbc.googlecode.com/files/pyodbc-3.0.2.win-amd64-py2.7.exe', '%LOCAL_RESOURCE_TMP_DIR%pyodbc.exe')"
%SystemDrive%\Zoo\Tools\7za x -o%LOCAL_RESOURCE_TMP_DIR%pyodbc -y %LOCAL_RESOURCE_TMP_DIR%pyodbc.exe
xcopy /e /h /y %LOCAL_RESOURCE_TMP_DIR%pyodbc\PLATLIB\* %PYTHON_INSTALL_DIR%\Lib\site-packages

:INSTALL_DJANGO_PYODBC
echo installing django-pyodbc...
%PYTHON_INSTALL_DIR%\python -c "import sql_server.pyodbc" 2>nul
if "%ERRORLEVEL%"=="0" goto INSTALL_MERCURIAL
cd /d %LOCAL_RESOURCE_TMP_DIR%
%LOCAL_RESOURCE_TMP_DIR%svn-win32\bin\svn export http://django-pyodbc.googlecode.com/svn/trunk/ django-pyodbc
cd .\django-pyodbc
%PYTHON_INSTALL_DIR%\python setup.py install
cd /d "%~dp0"


REM install django-mssql
:INSTALL_MERCURIAL
echo installing mercurial...
if exist "%ProgramFiles%\Mercurial\hg.exe" goto INSTALL_PYWIN32
set MERCURIAL_INSTALLER=mercurial-2.1.1-x86.msi
if exist "%ProgramFiles(x86)%" set MERCURIAL_INSTALLER=mercurial-2.1.1-x64.msi
powershell -c "(new-object System.Net.WebClient).DownloadFile('http://mercurial.selenic.com/release/windows/%MERCURIAL_INSTALLER%', '%LOCAL_RESOURCE_TMP_DIR%mercurial.msi')"
msiexec /i %LOCAL_RESOURCE_TMP_DIR%mercurial.msi /qn
set PATH=%PATH%;%ProgramFiles%\Mercurial
if not exist "%ProgramFiles%\Mercurial\hg.exe" echo ERROR: failed to install mercurial.

:INSTALL_PYWIN32
echo installing pywin32...
%PYTHON_INSTALL_DIR%\python -c "import win32com" 2>nul
if "%ERRORLEVEL%"=="0" goto INSTALL_DJANGO_MSSQL
set PYWIN32_INSTALLER=pywin32-217.win32-py2.7.exe
if "%PYTHON_X86%"=="0" set PYWIN32_INSTALLER=pywin32-217.win-amd64-py2.7.exe
powershell -c "(new-object System.Net.WebClient).DownloadFile('http://downloads.sourceforge.net/project/pywin32/pywin32/Build 217/%PYWIN32_INSTALLER%', '%LOCAL_RESOURCE_TMP_DIR%pywin32.exe')"
%SystemDrive%\Zoo\Tools\7za x -o%LOCAL_RESOURCE_TMP_DIR%pywin32 -y %LOCAL_RESOURCE_TMP_DIR%pywin32.exe
xcopy /e /h /y %LOCAL_RESOURCE_TMP_DIR%pywin32\PLATLIB\* %PYTHON_INSTALL_DIR%\Lib\site-packages
copy %LOCAL_RESOURCE_TMP_DIR%pywin32\SCRIPTS\* %PYTHON_INSTALL_DIR%\Scripts\
%PYTHON_INSTALL_DIR%\python %PYTHON_INSTALL_DIR%\Scripts\pywin32_postinstall.py -install

:INSTALL_DJANGO_MSSQL
echo installing django-mssql...
%PYTHON_INSTALL_DIR%\python -c "import sqlserver_ado" 2>nul
if "%ERRORLEVEL%"=="0" goto INSTALL_REQUIREMENTS
%SystemDrive%\Python27\Scripts\pip install hg+https://django-mssql.googlecode.com/hg/#egg=django-mssql


REM install other pure python packages
:INSTALL_REQUIREMENTS
echo installing required packages...
%SystemDrive%\Python27\Scripts\pip install --timeout=600 --default-timeout=600 -r ..\requirements.txt


echo Finished installation of the requirements.
echo Make sure that you run this command as an administrator if you have any error above.
