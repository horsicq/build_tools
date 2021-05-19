function check_file
{
    if test -f "$1"; then
        echo "Check file $1: TRUE"
    else
        export X_ERROR="true"
        echo "Cannot find file: $1"
    fi
}

function make_init
{
    export X_QT_VERSION=$($QMAKE_PATH -query QT_VERSION)
    export X_QT_INSTALL_BINS=$($QMAKE_PATH -query QT_INSTALL_BINS)
    export X_QT_INSTALL_PLUGINS=$($QMAKE_PATH -query QT_INSTALL_PLUGINS)
    export X_QT_INSTALL_LIBS=$($QMAKE_PATH -query QT_INSTALL_LIBS)
    export X_QMAKE_SPEC=$($QMAKE_PATH -query QMAKE_SPEC)
    mkdir -p "$X_SOURCE_PATH/release"
    mkdir -p "$X_SOURCE_PATH/release/$X_BUILD_NAME"
}

function make_build
{
    $QMAKE_PATH "$1" -spec $X_QMAKE_SPEC CONFIG+=x86_64
    make -f Makefile
}

function make_translate 
{
    "$X_QT_INSTALL_BINS/lupdate" $1
    "$X_QT_INSTALL_BINS/lrelease" $1
    mkdir -p "$X_SOURCE_PATH/release/$X_BUILD_NAME/$2.app/Contents/Resources/lang"
    mv translation/*.qm "$X_SOURCE_PATH/release/$X_BUILD_NAME/$2.app/Contents/Resources/lang/"
}

function make_release
{
    rm -rf $X_SOURCE_PATH/release/${X_BUILD_NAME}_${X_RELEASE_VERSION}.dmg
    hdiutil create -format UDBZ -quiet -srcfolder $X_SOURCE_PATH/release/$BUILD_NAME $X_SOURCE_PATH/release/${X_BUILD_NAME}_${X_RELEASE_VERSION}.dmg
    cd $X_SOURCE_PATH/release/
    rm -rf $X_SOURCE_PATH/release/${X_BUILD_NAME}_${X_RELEASE_VERSION}.zip
    zip -r $X_SOURCE_PATH/release/${X_BUILD_NAME}_${X_RELEASE_VERSION}.zip ${X_BUILD_NAME}
    cd $X_SOURCE_PATH
}

function make_clear
{
    rm -rf $X_SOURCE_PATH/release/$X_BUILD_NAME
}

function fixlibrary
{
    install_name_tool -change @rpath/$1.framework/Versions/5/$1 @executable_path/../Frameworks/$1.framework/Versions/5/$1  $2    
}

function fiximport
{
    fixlibrary QtWidgets $1
    fixlibrary QtGui $1
    fixlibrary QtCore $1  
    fixlibrary QtDBus $1
    fixlibrary QtPrintSupport $1
    fixlibrary QtSvg $1
    fixlibrary QtOpenGL $1
    fixlibrary QtConcurrent $1
}

function deploy_qt_library
{
    mkdir $X_SOURCE_PATH/release/$X_BUILD_NAME/$2.app/Contents/Frameworks
    mkdir $X_SOURCE_PATH/release/$X_BUILD_NAME/$2.app/Contents/Frameworks/$1.framework
    mkdir $X_SOURCE_PATH/release/$X_BUILD_NAME/$2.app/Contents/Frameworks/$1.framework/Versions
    mkdir $X_SOURCE_PATH/release/$X_BUILD_NAME/$2.app/Contents/Frameworks/$1.framework/Versions/5
    
    cp -R $X_QT_INSTALL_LIBS/$1.framework/Versions/5/$1 $X_SOURCE_PATH/release/$X_BUILD_NAME/$2.app/Contents/Frameworks/$1.framework/Versions/5
    
    install_name_tool -id @executable_path/../Frameworks/$1.framework/Versions/5/$1 $X_SOURCE_PATH/release/$X_BUILD_NAME/$2.app/Contents/Frameworks/$1.framework/Versions/5/$1
    fiximport $X_SOURCE_PATH/release/$X_BUILD_NAME/$2.app/Contents/Frameworks/$1.framework/Versions/5/$1
}

function deploy_qt_plugin
{
    mkdir $X_SOURCE_PATH/release/$X_BUILD_NAME/$3.app/Contents/PlugIns/
    mkdir $X_SOURCE_PATH/release/$X_BUILD_NAME/$3.app/Contents/PlugIns/$1/
    cp -R $X_QT_INSTALL_PLUGINS/$1/$2.dylib $X_SOURCE_PATH/release/$X_BUILD_NAME/$3.app/Contents/PlugIns/$1/
    
    install_name_tool -id @executable_path/../PlugIns/$1/$2.dylib $X_SOURCE_PATH/release/$X_BUILD_NAME/$3.app/Contents/PlugIns/$1/$2.dylib
    fiximport $X_SOURCE_PATH/release/$X_BUILD_NAME/$3.app/Contents/PlugIns/$1/$2.dylib
}