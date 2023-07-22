@echo off
setlocal enabledelayedexpansion

for /F "tokens=1,2*" %%i in ('reg query HKLM\Software\7-Zip-Zstandard /v Path') do (
    set "PATH=%%k;%PATH%"
)

7z >NUL
if not %errorlevel% == 0 (
    echo 7z.exe is required
    goto end
)

if not "%~1" == "" (
    set "installer=%~1"
) else if exist iTunes64Setup.exe (
    set installer=iTunes64Setup.exe
) else if exist iTunesSetup.exe (
    set installer=iTunesSetup.exe
) else (
    echo installer executable not found
    goto end
)

7z e -y "%installer%" iTunes.msi
7z e -y "%installer%" iTunes64.msi

if exist iTunes.msi (
    call :extract QTfiles iTunes.msi
)
if exist iTunes64.msi (
    call :extract QTfiles64 iTunes64.msi
)
goto end

:extract
mkdir %1
msiexec /a %2 /qn TARGETDIR="%cd%\__TMP__"
if not %errorlevel% == 0 (
    echo msiexec failed
    exit /b
)
move /Y __TMP__\iTunes\api-ms-win-*.dll %1
move /Y __TMP__\iTunes\icudt*.dll %1
for %%f in (ASL CoreAudioToolbox CoreFoundation libdispatch libicuin libicuuc objc) do (
    move /Y __TMP__\iTunes\%%f.dll %1
)
if exist __TMP__\System64 (
    move /Y __TMP__\System64\*.dll %1
)
if exist __TMP__\System (
    move /Y __TMP__\System\*.dll %1
)
if exist __TMP__\Win\System64 (
    move /Y __TMP__\Win\System64\*.dll %1
)
if exist __TMP__\Win\System (
    move /Y __TMP__\Win\System\*.dll %1
)
rd /s /q __TMP__
exit /b

:end
if exist iTunes.msi del iTunes.msi
if exist iTunes64.msi del iTunes64.msi
endlocal
