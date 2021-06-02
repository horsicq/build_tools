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
    
:make_init
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
    
:make_build
    IF EXIST "Makefile" (
        nmake Makefile clean
    )
    %QMAKE_PATH% "%~1" -r -spec %X_QMAKE_SPEC% "CONFIG+=release"
    nmake
    goto:eof
    
:make_translate
    %X_QT_INSTALL_BINS%\lupdate.exe "%~1"
    %X_QT_INSTALL_BINS%\lrelease.exe "%~1"
    mkdir %X_SOURCE_PATH%\release\%X_BUILD_NAME%\lang
    xcopy translation\*.qm  %X_SOURCE_PATH%\release\%X_BUILD_NAME%\lang\  /Y
    goto:eof
   
:deploy_qt_library
    copy %X_QT_INSTALL_BINS%\%~1.dll %X_SOURCE_PATH%\release\%X_BUILD_NAME%\
    goto:eof
    
:deploy_qt_plugin
    mkdir %X_SOURCE_PATH%\release\%X_BUILD_NAME%\%~1
    echo "%X_QT_INSTALL_PLUGINS%\%~1\%~2.dll %X_SOURCE_PATH%\release\%X_BUILD_NAME%\%~1\"
    copy %X_QT_INSTALL_PLUGINS%\%~1\%~2.dll %X_SOURCE_PATH%\release\%X_BUILD_NAME%\%~1\
    goto:eof
    
:deploy_vc_redist
    echo %VisualStudioVersion%
    if "%VisualStudioVersion%" == "12.0" (
        echo "Test1"
        copy "%VCINSTALLDIR%\redist\x86\Microsoft.VC120.CRT\msvcp120.dll" %X_SOURCE_PATH%\release\%X_BUILD_NAME%\
        copy "%VCINSTALLDIR%\redist\x86\Microsoft.VC120.CRT\msvcr120.dll" %X_SOURCE_PATH%\release\%X_BUILD_NAME%\
    )
    if "%VisualStudioVersion%" == "16.0" (
        copy "%VCToolsRedistDir%\%Platform%\Microsoft.VC142.CRT\msvcp140.dll" %X_SOURCE_PATH%\release\%X_BUILD_NAME%\
        copy "%VCToolsRedistDir%\%Platform%\Microsoft.VC142.CRT\vcruntime140.dll" %X_SOURCE_PATH%\release\%X_BUILD_NAME%\
        copy "%VCToolsRedistDir%\%Platform%\Microsoft.VC142.CRT\msvcp140_1.dll" %X_SOURCE_PATH%\release\%X_BUILD_NAME%\
        copy "%VCToolsRedistDir%\%Platform%\Microsoft.VC142.CRT\vcruntime140_1.dll" %X_SOURCE_PATH%\release\%X_BUILD_NAME%\
    )
    
    goto:eof
    
:make_release
    cd %X_SOURCE_PATH%\release
    set X_ZIP_NAME=%X_BUILD_NAME%_%X_RELEASE_VERSION%
    if exist %X_ZIP_NAME%.zip del %X_ZIP_NAME%.zip
    %SEVENZIP_PATH% a %X_ZIP_NAME%.zip %X_BUILD_NAME%\*
    set X_ZIP_NAME=
    cd %X_SOURCE_PATH%
    goto:eof 
    
:make_clear
    set X_ERROR=
    set X_QT_VERSION=
    set X_QT_INSTALL_BINS=
    set X_QT_INSTALL_PLUGINS=
    set X_QMAKE_SPEC=
    
    rmdir /s /q %X_SOURCE_PATH%\release\%X_BUILD_NAME%
    
    goto:eof
    
:exit
    exit /b