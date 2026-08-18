include(GNUInstallDirs)

if(WIN32)
    add_definitions(-DNOMINMAX)
endif()

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

# Respect existing C++ standard; default to 14 if not set
if(NOT DEFINED CMAKE_CXX_STANDARD)
    set(CMAKE_CXX_STANDARD 14)
endif()
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

if(WIN32)
    if (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
        set(CMAKE_EXE_LINKER_FLAGS    "${CMAKE_EXE_LINKER_FLAGS} /MANIFEST:NO")
        set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} /MANIFEST:NO")
        set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} /MANIFEST:NO")
    endif()
endif()

if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    message(STATUS "Using GNU Compiler")
    #TODO
elseif (CMAKE_CXX_COMPILER_ID STREQUAL "Clang" OR CMAKE_CXX_COMPILER_ID STREQUAL "AppleClang")
    message(STATUS "Using Clang Compiler")
    #TODO
elseif (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    message(STATUS "Using MSVC Compiler")
    #TODO
else ()
    message(WARNING "Unknown compiler: ${CMAKE_CXX_COMPILER_ID}")
endif()

# Suppress MSVC "unsafe" CRT deprecation warnings in legacy code paths
if(MSVC)
    add_compile_definitions(_CRT_SECURE_NO_WARNINGS _SCL_SECURE_NO_WARNINGS _CRT_NONSTDC_NO_DEPRECATE)

    # 2026-08-18: removed a global "/FIiterator" force-include that used to sit here as
    # a workaround for QTBUG-90568 (Qt 5.15's qvector.h/qlist.h/qvarlengtharray.h use
    # stdext::checked_array_iterator without including <iterator> themselves).
    # It was a verified no-op against this Qt 5.15.2 installation: QtCore/qbytearray.h
    # includes <string> and <iterator> unconditionally and is on the unconditional
    # include path of all three headers (QVector -> qvector.h -> qhashfunctions.h ->
    # qstring.h -> qbytearray.h -> <iterator>, per cl /showIncludes), so the bug cannot
    # occur. Compiler output was byte-identical with and without the flag.
    # It was also a hazard: the Visual Studio generator drops the COMPILE_LANGUAGE
    # genex and applies the forced include target-wide, so any C source added under a
    # scope using this helper failed with "STL1003: Unexpected compiler, expected C++
    # compiler".
    # If a future Qt or MSVC reintroduces the problem, reinstate it per source file
    # (set_source_files_properties(... COMPILE_OPTIONS /FIiterator)) or per C++-only
    # target -- NOT via a directory-level add_compile_options(), which the VS generator
    # will apply to C too.
endif()

if(NOT DEFINED X_RESOURCES)
    if(WIN32)
        set(X_RESOURCES ".")
    elseif(APPLE)
        set(X_RESOURCES "${PROJECT_NAME}.app/Contents/Resources")
    else()
        set(X_RESOURCES ${CMAKE_INSTALL_LIBDIR}/${PROJECT_NAME})
    endif()
endif()