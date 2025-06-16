@echo off

rem This program compresses the working folder and saves it as a backup in a designated location, such as a file server.
rem 1. Use it on the desktop.
rem 2. Configure the "settings" of this program appropriately.
rem 3. Drag and drop the target folder into this program.
rem 4. The folder will be compressed and saved in the pre-configured backup directory.
rem # Lhaplus needs to be installed.
rem # The settings are as follows.
rem =======================================================================
set lhaplusPath="C:\Program Files (x86)\Lhaplus\Lhaplus.exe"
set backupDir="C:\path\to\backupFolder\"
set password="password"
rem =======================================================================

if "%~1"=="" (
  echo folder not selected
  pause
  exit /b
)
if not exist %backupDir% (
  echo folder doesnt exist
  pause
  exit /b
) 
set "currentDir=%~1"
echo currentDir:%currentDir%
setlocal enabledelayedexpansion
for %%i in ("%currentDir%") do set "basename=%%~nxi"

echo %basename%

set "datetime=%date:~0,4%%date:~5,2%%date:~8,2%%time:~0,2%%time:~3,2%%time:~6,2%"
set "datetime=%datetime: =0%"
set "archiveName=%basename%_backup_%datetime%.zip"
echo %archiveName%
set "backupDirNoQuotes=%backupDir:~1,-1%"

if exist "%currentDir%\" (
    %lhaplusPath% /c:zip /p:%password% /n:"%backupDirNoQuotes%\%archiveName%" "%currentDir%\*"
) else (
    if exist "%currentDir%" (
        %lhaplusPath% /c:zip /p:%password% /n:"%backupDirNoQuotes%\%archiveName%" "%currentDir%"
    ) else (
        echo folder doesnt exist
        pause
        exit /b
    )
)

if exist "%backupDirNoQuotes%\%archiveName%" (
    echo backup complete: "%backupDirNoQuotes%\%archiveName%"
) else (
    echo backup failed. pause exit /b
)
echo do you want to open backup folder?(y/n)
set /p isopen=
if /i "%isopen%"=="y" (
    start "" "%backupDirNoQuotes%"
)
pause