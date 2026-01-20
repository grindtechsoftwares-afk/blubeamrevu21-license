@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM =========================
REM ADMIN CHECK
REM =========================
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo ❌ Run this script as Administrator!
    pause
    exit /b
)

REM =========================
REM DETECT EXTRACTOR
REM =========================
set "EXTRACTOR="
set "EX_CMD="

if exist "C:\Program Files\WinRAR\WinRAR.exe" (
    set "EXTRACTOR=C:\Program Files\WinRAR\WinRAR.exe"
    set "EX_CMD=rar"
) else if exist "C:\Program Files (x86)\WinRAR\WinRAR.exe" (
    set "EXTRACTOR=C:\Program Files (x86)\WinRAR\WinRAR.exe"
    set "EX_CMD=rar"
) else if exist "C:\Program Files\7-Zip\7z.exe" (
    set "EXTRACTOR=C:\Program Files\7-Zip\7z.exe"
    set "EX_CMD=7z"
) else (
    echo ❌ No extractor found! Install WinRAR or 7-Zip.
    pause
    exit /b
)

REM =========================
REM ARCHIVES & DESTINATIONS
REM =========================
set "ARCHIVE_X64=%~dp0x64 license.rar"
set "ARCHIVE_X86=%~dp0x86 license.rar"

set "DEST_X64=C:\Program Files\Bluebeam Software\Bluebeam Revu\21\Revu"
set "DEST_X86=C:\Program Files (x86)\Bluebeam Software\Bluebeam Revu\21\Revu"

set "TEMP_X64=%TEMP%\bb_x64_%RANDOM%"
set "TEMP_X86=%TEMP%\bb_x86_%RANDOM%"

REM =========================
REM FUNCTION : EXTRACT + COPY
REM =========================
call :PROCESS "%ARCHIVE_X64%" "%TEMP_X64%" "%DEST_X64%"
call :PROCESS "%ARCHIVE_X86%" "%TEMP_X86%" "%DEST_X86%"

echo.
echo ✅ ALL FILES PROCESSED SUCCESSFULLY
pause
exit /b

:PROCESS
set "ARCH=%~1"
set "TEMP_DIR=%~2"
set "DEST_DIR=%~3"

echo.
echo ▶ Processing: %ARCH%

if not exist "%ARCH%" (
    echo ⚠ File not found: %ARCH%
    goto :eof
)

if exist "%TEMP_DIR%" rd /s /q "%TEMP_DIR%"
mkdir "%TEMP_DIR%"
if not exist "%DEST_DIR%" mkdir "%DEST_DIR%"

if "%EX_CMD%"=="rar" (
    "%EXTRACTOR%" x "%ARCH%" "%TEMP_DIR%\" -y >nul
) else (
    "%EXTRACTOR%" x "%ARCH%" -o"%TEMP_DIR%" -y >nul
)

robocopy "%TEMP_DIR%" "%DEST_DIR%" /E /COPYALL /R:3 /W:2 >nul
rd /s /q "%TEMP_DIR%"

echo ✔ Done: %DEST_DIR%
goto :eof
