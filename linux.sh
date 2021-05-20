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
    X_ARCHITECTURE=$(uname -m)
    export X_REVISION=$(date "+%Y%m%d")

    if [[ $X_ARCHITECTURE == *"x86_64"* ]]; then
        X_ARCHITECTURE="amd64"
    fi
    export X_ARCHITECTURE

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
    make clean
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
    echo "make_release"
}

function create_app_dir
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

function make_deb
{
    dpkg -b $X_SOURCE_PATH/release/$X_BUILD_NAME
}

function make_clear
{
    rm -rf $X_SOURCE_PATH/release/$X_BUILD_NAME
}
