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
    X_UNAME=$(uname -m)
    export X_REVISION=$(date "+%Y%m%d")

    X_ARCHITECTURE="i386"
    if [[ $X_UNAME == *"x86_64"* ]]; then
        X_ARCHITECTURE="amd64"
    fi
    export X_ARCHITECTURE
    
    X_OS_NAME=$(lsb_release -is)
    X_OS_NUMBER=$(lsb_release -rs)

    export X_OS_VERSION=$X_OS_NAME_$X_OS_NUMBER
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
    if test -f "Makefile"; then
        make clean
    fi
    
    $QMAKE_PATH "$1" -spec $X_QMAKE_SPEC
    make -f Makefile
}

function make_translate 
{
    "$X_QT_INSTALL_BINS/lupdate" $1
    "$X_QT_INSTALL_BINS/lrelease" $1
}

function make_release
{
    # TODO
    echo "make_release"
}

function create_deb_app_dir
{
    mkdir -p $X_SOURCE_PATH/release/$X_BUILD_NAME/DEBIAN
    mkdir -p $X_SOURCE_PATH/release/$X_BUILD_NAME/usr
    mkdir -p $X_SOURCE_PATH/release/$X_BUILD_NAME/usr/bin
    mkdir -p $X_SOURCE_PATH/release/$X_BUILD_NAME/usr/lib
    mkdir -p $X_SOURCE_PATH/release/$X_BUILD_NAME/usr/lib/$1
    mkdir -p $X_SOURCE_PATH/release/$X_BUILD_NAME/usr/lib/$1/lang
    mkdir -p $X_SOURCE_PATH/release/$X_BUILD_NAME/usr/share
    mkdir -p $X_SOURCE_PATH/release/$X_BUILD_NAME/usr/share/applications
    mkdir -p $X_SOURCE_PATH/release/$X_BUILD_NAME/usr/share/icons
}

function create_image_app_dir
{
    mkdir -p $X_SOURCE_PATH/release/appDir
    mkdir -p $X_SOURCE_PATH/release/appDir/usr
    mkdir -p $X_SOURCE_PATH/release/appDir/usr/bin
    mkdir -p $X_SOURCE_PATH/release/appDir/usr/lib
    mkdir -p $X_SOURCE_PATH/release/appDir/usr/lib/$1
    mkdir -p $X_SOURCE_PATH/release/appDir/usr/lib/$1/lang
    mkdir -p $X_SOURCE_PATH/release/appDir/usr/share
    mkdir -p $X_SOURCE_PATH/release/appDir/usr/share/applications
    mkdir -p $X_SOURCE_PATH/release/appDir/usr/share/icons
}

function make_deb
{
    dpkg -b $X_SOURCE_PATH/release/$X_BUILD_NAME
}

function make_clear
{
    rm -rf $X_SOURCE_PATH/release/$X_BUILD_NAME
}
