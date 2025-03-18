set(X_PROJECT_ARCH ${CMAKE_SYSTEM_PROCESSOR})
message(STATUS CMAKE_SYSTEM_PROCESSOR: ${CMAKE_SYSTEM_PROCESSOR})
message(STATUS X_PROJECT_ARCH: ${X_PROJECT_ARCH})

if (WIN32)
    if (CMAKE_SIZEOF_VOID_P EQUAL 8)
        set(X_PROJECT_OSNAME "win64")
    else()
        set(X_PROJECT_OSNAME "win32")
    endif()

    if(MSVC)
        if(${MSVC_VERSION} EQUAL 1800)
            set(X_PROJECT_OSNAME "winxp")
            set(X_PROJECT_ARCH "x86")
        endif()
    endif()
endif()
if (CMAKE_SYSTEM_NAME MATCHES "Linux")
    execute_process (
        COMMAND bash -c ". /etc/os-release; echo -n $NAME"
        OUTPUT_VARIABLE X_OS_NAME
    )
    execute_process (
        COMMAND bash -c ". /etc/os-release; echo -n $VERSION_ID"
        OUTPUT_VARIABLE X_OS_VERSION
    )

    set(X_PROJECT_OSNAME ${X_OS_NAME}_${X_OS_VERSION})
    message(STATUS X_OS_NAME: ${X_OS_NAME})
    message(STATUS X_OS_VERSION: ${X_OS_VERSION})
    message(STATUS X_PROJECT_OSNAME: ${X_PROJECT_OSNAME})

    if (EXISTS "/etc/debian_version")
        file (STRINGS "/etc/debian_version" X_DEBIAN_VERSION)
        message(STATUS "X_DEBIAN_VERSION: ${X_DEBIAN_VERSION}")
        if (X_DEBIAN_VERSION MATCHES "squeeze")
            set(X_DEBIAN_VERSION "6")
        elseif (X_DEBIAN_VERSION MATCHES "squeeze")
            set(X_DEBIAN_VERSION "7")
        elseif (X_DEBIAN_VERSION MATCHES "squeeze")
            set(X_DEBIAN_VERSION "8")
        elseif (X_DEBIAN_VERSION MATCHES "squeeze")
            set(X_DEBIAN_VERSION "9")
        elseif (X_DEBIAN_VERSION MATCHES "squeeze")
            set(X_DEBIAN_VERSION "10")
        elseif (X_DEBIAN_VERSION MATCHES "squeeze")
            set(X_DEBIAN_VERSION "11")
        elseif (X_DEBIAN_VERSION MATCHES "bookworm")
            set(X_DEBIAN_VERSION "12")
        else()
            set(X_DEBIAN_VERSION "11")
        endif()

        set(X_DEBIAN_VERSION ${X_DEBIAN_VERSION})

        message(STATUS "X_DEBIAN_VERSION: ${X_DEBIAN_VERSION}")
        message(STATUS "CMAKE_SYSTEM_NAME: ${CMAKE_SYSTEM_NAME}")
    endif()
endif()

if(APPLE)
    set (CMAKE_OSX_ARCHITECTURES x86_64) # TODO make option
    add_compile_options(-Wno-deprecated-declarations)
    add_compile_options(-Wno-switch)
endif()

set(CPACK_INCLUDE_TOPLEVEL_DIRECTORY OFF)
set(CPACK_OUTPUT_FILE_PREFIX packages)
set(CPACK_RESOURCE_FILE_LICENSE "${PROJECT_SOURCE_DIR}/../LICENSE")
set(CPACK_RESOURCE_FILE_README "${PROJECT_SOURCE_DIR}/../README.md")
file (STRINGS "${PROJECT_SOURCE_DIR}/../release_version.txt" CPACK_PACKAGE_VERSION)
set(CPACK_PACKAGE_NAME ${X_PROJECTNAME})
set(CPACK_PACKAGE_INSTALL_DIRECTORY ${X_PROJECTNAME})
set(CPACK_PACKAGE_INSTALL_REGISTRY_KEY ${X_PROJECTNAME})
set(CPACK_PACKAGE_VENDOR ${X_COMPANYNAME})
set(CPACK_PACKAGE_DESCRIPTION ${X_DESCRIPTION})
set(CPACK_PACKAGE_HOMEPAGE_URL ${X_HOMEPAGE})

if (WIN32)
    set(CPACK_SOURCE_GENERATOR "ZIP")
    set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}_${X_PROJECT_OSNAME}_portable_${CPACK_PACKAGE_VERSION}_${X_PROJECT_ARCH}")
endif()

if (CMAKE_SYSTEM_NAME MATCHES "Linux")
    set(CPACK_SOURCE_GENERATOR "TGZ;DEB")
    set(CPACK_DEBIAN_PACKAGE_MAINTAINER ${X_MAINTAINER})
    set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}_${CPACK_PACKAGE_VERSION}_${X_PROJECT_OSNAME}_${X_PROJECT_ARCH}")
    message(STATUS CPACK_DEBIAN_PACKAGE_NAME: ${CPACK_DEBIAN_PACKAGE_NAME})
    #set(CPACK_DEBIAN_PACKAGE_SECTION ${X_SECTION})

    # Qt5
    if (NOT "${Qt5Core_VERSION}" STREQUAL "")
        if (X_DEBIAN_VERSION LESS 11)
            list(APPEND X_DEBIAN_PACKAGE_DEPENDS "qt5-default")
        endif()
        list(APPEND X_DEBIAN_PACKAGE_DEPENDS "libqt5core5a")
        list(APPEND X_DEBIAN_PACKAGE_DEPENDS "libqt5dbus5") # TODO Check
    endif()
    if (NOT "${Qt5Gui_VERSION}" STREQUAL "")
        list(APPEND X_DEBIAN_PACKAGE_DEPENDS "libqt5gui5")
    endif()
    if (NOT "${Qt5Widgets_VERSION}" STREQUAL "")
        list(APPEND X_DEBIAN_PACKAGE_DEPENDS "libqt5widgets5")
    endif()
    if (NOT "${Qt5Svg_VERSION}" STREQUAL "")
        list(APPEND X_DEBIAN_PACKAGE_DEPENDS "libqt5svg5")
    endif()
    if (NOT "${Qt5Sql_VERSION}" STREQUAL "")
        list(APPEND X_DEBIAN_PACKAGE_DEPENDS "libqt5sql5")
    endif()
    if (NOT "${Qt5OpenGL_VERSION}" STREQUAL "")
        list(APPEND X_DEBIAN_PACKAGE_DEPENDS "libqt5opengl5")
    endif()
    if (NOT "${Qt5Network_VERSION}" STREQUAL "")
        list(APPEND X_DEBIAN_PACKAGE_DEPENDS "libqt5network5")
    endif()
    if (NOT "${Qt5Script_VERSION}" STREQUAL "")
        list(APPEND X_DEBIAN_PACKAGE_DEPENDS "libqt5script5")
    endif()
    if (NOT "${Qt5ScriptTools_VERSION}" STREQUAL "")
        list(APPEND X_DEBIAN_PACKAGE_DEPENDS "libqt5scripttools5")
    endif()
    # Qt6
    if (NOT "${Qt6Core_VERSION}" STREQUAL "")
        list(APPEND X_DEBIAN_PACKAGE_DEPENDS "libqt6core6")
    endif()
    if (NOT "${Qt6Gui_VERSION}" STREQUAL "")
        list(APPEND X_DEBIAN_PACKAGE_DEPENDS "libqt6gui6")
    endif()
    if (NOT "${Qt6Widgets_VERSION}" STREQUAL "")
        list(APPEND X_DEBIAN_PACKAGE_DEPENDS "libqt6widgets6")
    endif()
    if (NOT "${Qt6Sql_VERSION}" STREQUAL "")
        list(APPEND X_DEBIAN_PACKAGE_DEPENDS "libqt6sql6")
    endif()
    if (NOT "${Qt6Network_VERSION}" STREQUAL "")
        list(APPEND X_DEBIAN_PACKAGE_DEPENDS "libqt6network6")
    endif()

    string(REPLACE ";" ", " CPACK_DEBIAN_PACKAGE_DEPENDS "${X_DEBIAN_PACKAGE_DEPENDS}")
    message(STATUS CPACK_DEBIAN_PACKAGE_DEPENDS: ${CPACK_DEBIAN_PACKAGE_DEPENDS})
endif()

if(APPLE)
    set(CPACK_GENERATOR "Bundle;productbuild;ZIP")
    set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}_${CPACK_PACKAGE_VERSION}_${X_PROJECT_OSNAME}_${X_PROJECT_ARCH}")
    set(CPACK_BUNDLE_NAME ${X_PROJECTNAME})
    set(CPACK_BUNDLE_ICON "${PROJECT_SOURCE_DIR}/../res/main.icns")
    set(CPACK_BUNDLE_PLIST "${PROJECT_SOURCE_DIR}/../res/Info.plist")
    set(CPACK_PRODUCTBUILD_IDENTIFIER ${BUNDLE_ID_OPTION})
endif()

include(CPack)

if(WIN32)
    configure_file("${PROJECT_SOURCE_DIR}/../res/resource.rc.in" "${PROJECT_SOURCE_DIR}/../res/resource.rc" @ONLY)
    configure_file("${PROJECT_SOURCE_DIR}/../res/resource_icon.rc.in" "${PROJECT_SOURCE_DIR}/../res/resource_icon.rc" @ONLY)
endif()

# get_cmake_property(_variableNames VARIABLES)
# list (SORT _variableNames)
# foreach (_variableName ${_variableNames})
#     message(STATUS "${_variableName}=${${_variableName}}")
# endforeach()

# foreach(loopVAR IN LISTS PROJECT_SOURCES)
#    message("Source from a PROJECT_SOURCES: ${loopVAR}")
#    set_property(SOURCE ${loopVAR} PROPERTY COMPILE_OPTIONS ${a_FLAGS})
# endforeach()
