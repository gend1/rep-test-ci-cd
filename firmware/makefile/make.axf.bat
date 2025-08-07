@echo off
echo %TIME%

echo ========================================================================
echo Compiling in process..
echo ========================================================================

del *.o.map 2>nul
del *.o.s 2>nul
del *.o 2>nul
del *.map 2>nul
del *.axf 2>nul
del *.axf.map 2>nul
del *.axf.s 2>nul
del *.axf.bin 2>nul
del *.axf.bin.ntl00 2>nul
del *.log 2>nul

setlocal enabledelayedexpansion

REM --------------------------------------------
set "ARCH=arm-none-eabi"
set "AS=%ARCH%-as"
set "CC=%ARCH%-gcc"
set "OBJCOPY=%ARCH%-objcopy"
set "OBJFILE=main.o"
set "INCLUDEPATH=-I..\src\sys"
set "MARCH=-march=armv5te -g"
set "CFLAGS=-Os"
REM --------------------------------------------

%AS% %MARCH% -c "..\src\sys\start.s" -o "start.o"
if errorlevel 1 (
    echo [ERROR] The assembly failed.
REM    exit /b 1
)

%CC% %MARCH% %CFLAGS% %INCLUDEPATH% -c "..\src\sys\main.c" -o "%OBJFILE%"
if errorlevel 1 (
    echo [ERROR] Compiling failed.
REM    exit /b 1
)

REM ____________________Для release версии________________________
REM ---- Линковка в ELF-файл ----
%CC% %MARCH% %CFLAGS% %INCLUDEPATH% -T linker_script.release.ld -o "release.axf"  "start.o" "%OBJFILE%" -nostdlib
if errorlevel 1 (
    echo [ERROR release] Linking failed.
REM    exit /b 1
)

REM ---- Преобразование бинарного образа ----
%OBJCOPY% "release.axf" -O binary "release.axf.bin"
if errorlevel 1 (
    echo [ERROR release] Conversion to binary failed.
REM    exit /b 1
)
REM ______________________________________________________________

REM ____________________Для debug версии________________________
REM ---- Линковка в ELF-файл ----
%CC% %MARCH% %CFLAGS% %INCLUDEPATH% -T linker_script.debug.ld -o "debug.axf"  "start.o" "%OBJFILE%" -nostdlib
if errorlevel 1 (
    echo [ERROR debug] Linking failed.
REM    exit /b 1
)

REM ---- Преобразование бинарного образа ----
%OBJCOPY% "debug.axf" -O binary "debug.axf.bin"
if errorlevel 1 (
    echo [ERROR debug] Conversion to binary failed.
REM    exit /b 1
)
REM ______________________________________________________________

REM pause
REM exit

echo ========================================================================
echo Assembly completed successfully!
echo release.axf      (ELF)
echo release.axf.bin  (binary image)
echo debug.axf        (ELF)
echo debug.axf.bin    (binary image)
echo ========================================================================

echo Running the script .remap...
"C:\Program Files\Git\usr\bin\bash.exe" "%~dp0.remap"
if errorlevel 1 (
    echo [Warning] Script .remap failed with error.
	echo ----------------------
) else (
    echo The .remap script completed successfully.
	echo ----------------------
)

echo Running the script .reasm...
"C:\Program Files\Git\usr\bin\bash.exe" "%~dp0.reasm"
if errorlevel 1 (
    echo [Warning] Script .reasm failed with error.
	echo ----------------------
) else (
    echo The .reasm script completed successfully.
	echo ----------------------
)

echo Running the script r.ntl00...
"C:\Program Files\Git\usr\bin\bash.exe" "%~dp0r.ntl00"
if errorlevel 1 (
    echo [Warning] Script r.ntl00 failed with error.
	echo ----------------------
) else (
    echo The r.ntl00 script completed successfully.
	echo ----------------------
)

echo %TIME%
pause
exit
