@echo off
call:%~1 "%~2"
goto exit

:check_file
    IF EXIST "%~1" (
        echo "Check file:  %~1: TRUE"
    ) ELSE (
        set X_ERROR="TRUE"
        echo "Cannot find file: %~1"
    )
    goto:eof
    
:init
    rem call %VSVARS_PATH%
    %QMAKE_PATH% -query QT_VERSION > qt_tmp.txt
    set /p X_QT_VERSION=<qt_tmp.txt
    %QMAKE_PATH% -query QT_INSTALL_BINS > qt_tmp.txt
    set /p X_QT_INSTALL_BINS=<qt_tmp.txt
    %QMAKE_PATH% -query QT_INSTALL_PLUGINS > qt_tmp.txt
    set /p X_QT_INSTALL_PLUGINS=<qt_tmp.txt
    %QMAKE_PATH% -query QMAKE_SPEC > qt_tmp.txt
    set /p X_QMAKE_SPEC=<qt_tmp.txt
    del qt_tmp.txt
    goto:eof
    
:build
    nmake clean
    %QMAKE_PATH% "%~1" -r -spec win32-msvc "CONFIG+=release"
    nmake
    goto:eof
    
:translate
    %X_QT_INSTALL_BINS%\lupdate.exe "%~1"
    %X_QT_INSTALL_BINS%\lrelease.exe "%~1"
    goto:eof
    
:clear
    set X_ERROR=
    set X_QT_VERSION=
    set X_QT_INSTALL_BINS=
    set X_QT_INSTALL_PLUGINS=
    set X_QMAKE_SPEC=
    goto:eof
    
:exit
    exit /b