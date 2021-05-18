@echo off
call:%~1 "%~2" "%~3"
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
    call %VSVARS_PATH%
    %QMAKE_PATH% -query QT_VERSION > qt_tmp.txt
    set /p X_QT_VERSION=<qt_tmp.txt
    %QMAKE_PATH% -query QT_INSTALL_BINS > qt_tmp.txt
    set /p X_QT_INSTALL_BINS=<qt_tmp.txt
    %QMAKE_PATH% -query QT_INSTALL_PLUGINS > qt_tmp.txt
    set /p X_QT_INSTALL_PLUGINS=<qt_tmp.txt
    %QMAKE_PATH% -query QMAKE_SPEC > qt_tmp.txt
    set /p X_QMAKE_SPEC=<qt_tmp.txt
    del qt_tmp.txt
    
    set X_QT_INSTALL_BINS=%X_QT_INSTALL_BINS:/=\%
    set X_QT_INSTALL_PLUGINS=%X_QT_INSTALL_PLUGINS:/=\%
    
    mkdir %X_SOURCE_PATH%\release
    mkdir %X_SOURCE_PATH%\release\%X_BUILD_NAME%
    
    goto:eof
    
:build
    nmake Makefile clean
    %QMAKE_PATH% "%~1" -r -spec win32-msvc "CONFIG+=release"
    nmake
    goto:eof
    
:translate
    %X_QT_INSTALL_BINS%\lupdate.exe "%~1"
    %X_QT_INSTALL_BINS%\lrelease.exe "%~1"
    mkdir %X_SOURCE_PATH%\release\%X_BUILD_NAME%\lang
    move translation\*.qm  %X_SOURCE_PATH%\release\%X_BUILD_NAME%\lang\
    goto:eof
   
:deploy_qt_library
    copy %X_QT_INSTALL_BINS%\%~1.dll %X_SOURCE_PATH%\release\%X_BUILD_NAME%\
    goto:eof
    
:deploy_qt_plugin
    mkdir %X_SOURCE_PATH%\release\%X_BUILD_NAME%\%~1
    echo "%X_QT_INSTALL_PLUGINS%\%~1\%~2.dll %X_SOURCE_PATH%\release\%X_BUILD_NAME%\%~1\"
    copy %X_QT_INSTALL_PLUGINS%\%~1\%~2.dll %X_SOURCE_PATH%\release\%X_BUILD_NAME%\%~1\
    goto:eof
    
:make_release
    cd %X_SOURCE_PATH%\release
    set X_ZIP_NAME=%X_BUILD_NAME%_%X_RELEASE_VERSION%
    if exist %X_ZIP_NAME%.zip del %X_ZIP_NAME%.zip
    %SEVENZIP_PATH% a %X_ZIP_NAME%.zip %X_BUILD_NAME%\*
    set X_ZIP_NAME=
    cd %X_SOURCE_PATH%
    goto:eof 
    
:clear
    set X_ERROR=
    set X_QT_VERSION=
    set X_QT_INSTALL_BINS=
    set X_QT_INSTALL_PLUGINS=
    set X_QMAKE_SPEC=
    
    rmdir /s /q %X_SOURCE_PATH%\release\%X_BUILD_NAME%
    
    goto:eof
    
:exit
    exit /b