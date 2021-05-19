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