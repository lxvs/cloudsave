@echo off
@setlocal

@REM =======================================================================
@set "steamFolder=%programfiles(x86)%\Steam"
@set "steamUserId=324014709"
@set "steamCommon=%steamFolder%\steamapps\common"
@set "cloudFolder=%steamFolder%\userdata\%steamUserId%"
@set "documents=%USERPROFILE%\Documents"
@set "mygames=%documents%\My Games"
@set "savedgames=%USERPROFILE%\Saved Games"
@set "localLowAppData=%USERPROFILE%\AppData\LocalLow"
@REM =======================================================================

@set "version=v1.1.0"
@set "lupdate=2021-05-23"
@title Cloud Save Linker %version%
@echo;
@echo     Cloud Save Linker %version%
@echo     https://github.com/lxvs/cloud
@echo     Last update: %lupdate%
@echo;

@pushd %~dp0

if not exist "%mygames%" md "%mygames%"
if not exist "%savedgames%" md "%savedgames%"
if not exist "%documents%\Klei" (
    if exist "DoNotStarveTogether" md "%documents%\Klei"
    if exist "OxygenNotIncluded" md "%documents%\Klei" 2>nul
)

@if not exist gamelist if not exist gamelist-steamcloud (
    @>&2 echo ERROR: could not find file 'gamelist' or 'gamelist-steamcloud'!
    @pause
    @popd
    exit /b 1
)

@if exist gamelist for /f "eol=$ tokens=1,2 delims=|" %%a in (gamelist) do @call:Link "%%a" "%%b" || @exit /b

@if exist gamelist-steamcloud for /f "eol=$ tokens=1,2 delims=|" %%a in (gamelist-steamcloud) do @call:LinkC "%%a" "%%b" || @exit /b

@echo ^> All finished.
@pause
@popd
exit /b 0

:Link
if exist %1 (
    @echo %~1
    if not exist "%~dp2" (
        @echo ^> Game is not installed.
        @echo;
        @exit /b
    )
    if not exist "%~2" (
        mklink /d "%~2" "%cd%\%~1" >nul 2>&1 || goto failed
        @echo ^> Finished.
    ) else call:LinkOW %1 %2 || exit /b
    @echo;
)
exit /b

:LinkOW
set owcfm=
set /p owcfm="> There have been save files of %~1, input Y to overwrite: "
if /i "%owcfm%"=="Y" (
    rd /s /q "%~2"
    mklink /d "%~2" "%cd%\%~1" >nul 2>&1 || goto failed
    @echo ^> Finished.
) else @echo ^> Ignored.
exit /b

:LinkC
if exist "%~2" (
    @echo %~2
    if not exist "%cloudFolder%" md "%cloudFolder%"
    if not exist "%cloudFolder%\%~1" (
        mklink /d "%cloudFolder%\%~1" "%cd%\%~2" >nul 2>&1 || goto failed
        @echo ^> Finished.
    ) else call:LinkCOW %1 %2 || exit /b
    @echo;
)
@exit /b

:LinkCOW
set owcfm=
set /p owcfm="> There have been save files of %~2, input Y to overwrite: "
if /i "%owcfm%"=="Y" (
    rd /s /q "%cloudFolder%\%~1"
    mklink /d "%cloudFolder%\%~1" "%cd%\%~2" >nul 2>&1 || goto failed
    @echo ^> Finished.
) else @echo ^> Ignored.
@exit /b

:failed
@echo ^> ERROR: Please run this as administrator.
@pause
@popd
exit /b 1