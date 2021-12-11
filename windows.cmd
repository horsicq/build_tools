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
    echo "init"
:msvc_env
    IF [%VSVARS_PATH%] == [] goto mingw_env
    call %VSVARS_PATH%
    set X_MAKE=nmake
    goto qmake_env
:mingw_env
    IF [%MINGWVARS_PATH%] == [] goto qmake_env
    call %MINGWVARS_PATH%
    set X_MAKE=mingw32-make
    goto qmake_env
    set X_ERROR="TRUE"
    echo "Please set MSVC or MinGW"
:qmake_env
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
    mkdir %X_SOURCE_PATH%\build\release
    
    if exist %X_SOURCE_PATH%\gui_source\ (
        xcopy %X_SOURCE_PATH%\build_tools\windows.manifest.xml %X_SOURCE_PATH%\gui_source\ /Y
    )
    
    if exist %X_SOURCE_PATH%\console_source\ (
        xcopy %X_SOURCE_PATH%\build_tools\windows.manifest.xml %X_SOURCE_PATH%\console_source\ /Y
    )
    
    if exist %X_SOURCE_PATH%\lite_source\ (
        xcopy %X_SOURCE_PATH%\build_tools\windows.manifest.xml %X_SOURCE_PATH%\lite_source\ /Y
    )
    
    xcopy %X_SOURCE_PATH%\build_tools\build.pri %X_SOURCE_PATH%\ /Y
    
    goto:eof
    
:make_build
    IF EXIST "Makefile" (
        %X_MAKE% clean
    )
    %QMAKE_PATH% "%~1" -r -spec %X_QMAKE_SPEC% "CONFIG+=release"
    %X_MAKE%
    goto:eof
    
:make_build_pdb
    IF EXIST "Makefile" (
        %X_MAKE% clean
    )
    %QMAKE_PATH% "%~1" -r -spec %X_QMAKE_SPEC% "CONFIG+=release" "DEFINES+=CREATE_PDB"
    %X_MAKE%
    goto:eof
    
:make_translate
    %X_QT_INSTALL_BINS%\lupdate.exe "%~1"
    %X_QT_INSTALL_BINS%\lrelease.exe "%~1"
    mkdir %X_SOURCE_PATH%\release\%X_BUILD_NAME%\lang
    xcopy translation\*.qm  %X_SOURCE_PATH%\release\%X_BUILD_NAME%\lang\  /Y
    goto:eof
    
:deploy_qt
    %X_QT_INSTALL_BINS%\windeployqt.exe %X_SOURCE_PATH%\release\%X_BUILD_NAME%\%~1
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
    
:deploy_redist
    if "%VisualStudioVersion%" == "12.0" (
        copy "%VCINSTALLDIR%\redist\x86\Microsoft.VC120.CRT\msvcp120.dll" %X_SOURCE_PATH%\release\%X_BUILD_NAME%\
        copy "%VCINSTALLDIR%\redist\x86\Microsoft.VC120.CRT\msvcr120.dll" %X_SOURCE_PATH%\release\%X_BUILD_NAME%\
    )
    if "%VisualStudioVersion%" == "16.0" (
        copy "%VCToolsRedistDir%\%Platform%\Microsoft.VC142.CRT\msvcp140.dll" %X_SOURCE_PATH%\release\%X_BUILD_NAME%\
        copy "%VCToolsRedistDir%\%Platform%\Microsoft.VC142.CRT\vcruntime140.dll" %X_SOURCE_PATH%\release\%X_BUILD_NAME%\
        copy "%VCToolsRedistDir%\%Platform%\Microsoft.VC142.CRT\msvcp140_1.dll" %X_SOURCE_PATH%\release\%X_BUILD_NAME%\
        copy "%VCToolsRedistDir%\%Platform%\Microsoft.VC142.CRT\vcruntime140_1.dll" %X_SOURCE_PATH%\release\%X_BUILD_NAME%\
    )
    if "%X_QMAKE_SPEC%" == "win32-g++" (
        copy "%X_QT_INSTALL_BINS%\libgcc_s_dw2-1.dll" %X_SOURCE_PATH%\release\%X_BUILD_NAME%\
        copy "%X_QT_INSTALL_BINS%\libstdc++-6.dll" %X_SOURCE_PATH%\release\%X_BUILD_NAME%\
        copy "%X_QT_INSTALL_BINS%\libwinpthread-1.dll" %X_SOURCE_PATH%\release\%X_BUILD_NAME%\
    )
    rem TODO more
    
    goto:eof
    
:make_release
    cd %X_SOURCE_PATH%\release
    set X_ZIP_NAME=%X_BUILD_NAME%_%X_BUILD_PREFIX%_portable_%X_RELEASE_VERSION%
    if exist %X_ZIP_NAME%.zip del %X_ZIP_NAME%.zip
    cd %X_SOURCE_PATH%\release\%X_BUILD_NAME%\
    
    %SEVENZIP_PATH% a %X_SOURCE_PATH%\release\%X_ZIP_NAME%.zip *
    set X_ZIP_NAME=
    cd %X_SOURCE_PATH%
    IF [%INNOSETUP_PATH%] == [] goto make_release_end
    %INNOSETUP_PATH% install.iss
    if exist "%X_SOURCE_PATH%\release\%X_BUILD_NAME%_%X_BUILD_PREFIX%_install_%X_RELEASE_VERSION%.exe" del "%X_SOURCE_PATH%\release\%X_BUILD_NAME%_%X_BUILD_PREFIX%_install_%X_RELEASE_VERSION%.exe"
    ren "%X_SOURCE_PATH%\release\install.exe" "%X_BUILD_NAME%_%X_BUILD_PREFIX%_install_%X_RELEASE_VERSION%.exe"
:make_release_end
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
