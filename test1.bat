@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

set "path_code=code"
set "path_test=Test"
set "CC=gcc"

set "args_3_2=apple mango ant banana cat anaconda"

for %%X in ("%path_code%\*.c") do (
    set "name=%%~nX"
    %CC% "%%~fX" -o "%path_code%\!name!.exe" 2>nul
    if not exist "%path_code%\!name!.exe" (
        echo !name!: COMPILE FAIL
    ) else if exist "%path_test%\!name!-out.txt" (
        set "infile=%path_test%\!name!-in.txt"
        if /I "!name!"=="3-2" (
            set "run_args=!args_3_2!"
        ) else (
            set "run_args="
        )
        if exist "!infile!" (
            if defined run_args (
                "%path_code%\!name!.exe" !run_args! < "!infile!" > "%path_test%\actual-!name!.txt"
            ) else (
                "%path_code%\!name!.exe" < "!infile!" > "%path_test%\actual-!name!.txt"
            )
        ) else (
            if defined run_args (
                "%path_code%\!name!.exe" !run_args! > "%path_test%\actual-!name!.txt"
            ) else (
                "%path_code%\!name!.exe" > "%path_test%\actual-!name!.txt"
            )
        )
        fc /b "%path_test%\actual-!name!.txt" "%path_test%\!name!-out.txt" >nul 2>&1
        if errorlevel 1 (
            echo !name!-out.txt: FAIL
        ) else (
            echo !name!-out.txt: PASS
        )
        del "%path_test%\actual-!name!.txt" 2>nul
    ) else if exist "%path_test%\!name!-out0.txt" (
        call :run_numbered !name!
    ) else (
        echo !name!: SKIP ^(no !name!-out.txt in Test^)
    )
)

endlocal
goto :eof

:run_numbered
set "rn_name=%~1"
set /a rn_n=0
:rn_loop
if not exist "%path_test%\%rn_name%-out%rn_n%.txt" goto rn_done
set "rn_in=%path_test%\%rn_name%-in%rn_n%.txt"
if /I "%rn_name%"=="3-2" (
    set "rn_args=%args_3_2%"
) else (
    set "rn_args="
)
if exist "%rn_in%" (
    if defined rn_args (
        "%path_code%\%rn_name%.exe" %rn_args% < "%rn_in%" > "%path_test%\actual-%rn_name%-%rn_n%.txt"
    ) else (
        "%path_code%\%rn_name%.exe" < "%rn_in%" > "%path_test%\actual-%rn_name%-%rn_n%.txt"
    )
) else (
    if defined rn_args (
        "%path_code%\%rn_name%.exe" %rn_args% > "%path_test%\actual-%rn_name%-%rn_n%.txt"
    ) else (
        "%path_code%\%rn_name%.exe" > "%path_test%\actual-%rn_name%-%rn_n%.txt"
    )
)
fc /b "%path_test%\actual-%rn_name%-%rn_n%.txt" "%path_test%\%rn_name%-out%rn_n%.txt" >nul 2>&1
if errorlevel 1 (
    echo %rn_name%-out%rn_n%.txt: FAIL
) else (
    echo %rn_name%-out%rn_n%.txt: PASS
)
del "%path_test%\actual-%rn_name%-%rn_n%.txt" 2>nul
set /a rn_n+=1
goto rn_loop
:rn_done
exit /b 0
