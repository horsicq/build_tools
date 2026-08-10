set(X_PROJECT_ARCH ${CMAKE_SYSTEM_PROCESSOR})
message(STATUS CMAKE_SYSTEM_PROCESSOR: ${CMAKE_SYSTEM_PROCESSOR})

if(NOT DEFINED X_RESOURCE_DIR)
    set(X_RESOURCE_DIR "${PROJECT_SOURCE_DIR}/../res")
endif()

if(NOT DEFINED X_WINDOWS_ICON)
    set(X_WINDOWS_ICON "${X_RESOURCE_DIR}/main.ico")
endif()
if(NOT DEFINED X_WINDOWS_RESOURCE_RC_IN)
    set(X_WINDOWS_RESOURCE_RC_IN "${X_RESOURCE_DIR}/resource.rc.in")
endif()
if(NOT DEFINED X_WINDOWS_RESOURCE_ICON_RC_IN)
    set(X_WINDOWS_RESOURCE_ICON_RC_IN "${X_RESOURCE_DIR}/resource_icon.rc.in")
endif()
if(NOT DEFINED X_WINDOWS_RESOURCE_RC)
    set(X_WINDOWS_RESOURCE_RC "${X_RESOURCE_DIR}/resource.rc")
endif()
if(NOT DEFINED X_WINDOWS_RESOURCE_ICON_RC)
    set(X_WINDOWS_RESOURCE_ICON_RC "${X_RESOURCE_DIR}/resource_icon.rc")
endif()
if(NOT DEFINED X_MACOS_ICON)
    set(X_MACOS_ICON "${X_RESOURCE_DIR}/main.icns")
endif()
if(NOT DEFINED X_MACOS_INFO_PLIST_IN)
    set(X_MACOS_INFO_PLIST_IN "${X_RESOURCE_DIR}/Info.plist.in")
endif()
if(NOT DEFINED X_MACOS_INFO_PLIST)
    set(X_MACOS_INFO_PLIST "${X_RESOURCE_DIR}/Info.plist")
endif()

if (WIN32)
    if (CMAKE_SIZEOF_VOID_P EQUAL 8)
        set(X_PROJECT_OSNAME "win64")
    else()
        set(X_PROJECT_OSNAME "win32")
    endif()

    if(MSVC)
        set(_x_project_vs_platform "")

        if(DEFINED CMAKE_VS_PLATFORM_NAME AND NOT "${CMAKE_VS_PLATFORM_NAME}" STREQUAL "")
            set(_x_project_vs_platform "${CMAKE_VS_PLATFORM_NAME}")
        elseif(DEFINED CMAKE_GENERATOR_PLATFORM AND NOT "${CMAKE_GENERATOR_PLATFORM}" STREQUAL "")
            set(_x_project_vs_platform "${CMAKE_GENERATOR_PLATFORM}")
        elseif(DEFINED ENV{Platform} AND NOT "$ENV{Platform}" STREQUAL "")
            set(_x_project_vs_platform "$ENV{Platform}")
        endif()

        if(_x_project_vs_platform STREQUAL "Win32" OR _x_project_vs_platform STREQUAL "x86")
            set(X_PROJECT_ARCH "x86")
        elseif(_x_project_vs_platform STREQUAL "x64" OR _x_project_vs_platform STREQUAL "AMD64")
            set(X_PROJECT_ARCH "x64")
        elseif(_x_project_vs_platform STREQUAL "ARM64")
            set(X_PROJECT_ARCH "arm64")
        elseif(_x_project_vs_platform STREQUAL "ARM")
            set(X_PROJECT_ARCH "arm")
        endif()

        if(${MSVC_VERSION} EQUAL 1800)
            set(X_PROJECT_OSNAME "winxp")
            set(X_PROJECT_ARCH "x86")
        endif()
    endif()
endif()
message(STATUS X_PROJECT_ARCH: ${X_PROJECT_ARCH})
if (CMAKE_SYSTEM_NAME MATCHES "Linux")
    # NAME is a human-readable label and commonly contains spaces or a slash
    # (for example "Debian GNU/Linux"). Package filenames use the stable ID
    # field and a strictly bounded filename-safe VERSION_ID instead.
    set(_x_linux_package_label_helper
        "${CMAKE_CURRENT_LIST_DIR}/linux_package_os_label.cmake")
    if(NOT EXISTS "${_x_linux_package_label_helper}")
        message(FATAL_ERROR
            "Linux package-label helper is missing: "
            "${_x_linux_package_label_helper}")
    endif()
    include("${_x_linux_package_label_helper}")
    x_get_linux_package_os_label(
        "/etc/os-release"
        X_PROJECT_OSNAME
        X_OS_NAME
        X_OS_VERSION)
    message(STATUS X_OS_NAME: ${X_OS_NAME})
    message(STATUS X_OS_VERSION: ${X_OS_VERSION})
    message(STATUS X_PROJECT_OSNAME: ${X_PROJECT_OSNAME})
    unset(_x_linux_package_label_helper)

    if (EXISTS "/etc/debian_version")
            file (STRINGS "/etc/debian_version" X_DEBIAN_VERSION)
            message(STATUS "X_DEBIAN_VERSION: ${X_DEBIAN_VERSION}")
            if (X_DEBIAN_VERSION MATCHES "squeeze")
                set(X_DEBIAN_VERSION "6")
            elseif (X_DEBIAN_VERSION MATCHES "wheezy")
                set(X_DEBIAN_VERSION "7")
            elseif (X_DEBIAN_VERSION MATCHES "jessie")
                set(X_DEBIAN_VERSION "8")
            elseif (X_DEBIAN_VERSION MATCHES "stretch")
                set(X_DEBIAN_VERSION "9")
            elseif (X_DEBIAN_VERSION MATCHES "buster")
                set(X_DEBIAN_VERSION "10")
            elseif (X_DEBIAN_VERSION MATCHES "bullseye")
                set(X_DEBIAN_VERSION "11")
            elseif (X_DEBIAN_VERSION MATCHES "bookworm")
                set(X_DEBIAN_VERSION "12")
            elseif (X_DEBIAN_VERSION MATCHES "trixie")
                set(X_DEBIAN_VERSION "13")
            else()
                set(X_DEBIAN_VERSION "Unknown")
            endif()

            set(X_DEBIAN_VERSION ${X_DEBIAN_VERSION})

            message(STATUS "X_DEBIAN_VERSION: ${X_DEBIAN_VERSION}")
            message(STATUS "CMAKE_SYSTEM_NAME: ${CMAKE_SYSTEM_NAME}")
        endif()
endif()

if(APPLE)
    set(X_PROJECT_OSNAME "macOS")
    # CMAKE_OSX_ARCHITECTURES affects compiler selection and must be supplied
    # before project() when cross-building. Do not silently force x86_64 here:
    # doing so produced x86_64 binaries labelled as arm64 on Apple Silicon.
    if(DEFINED CMAKE_OSX_ARCHITECTURES
       AND NOT "${CMAKE_OSX_ARCHITECTURES}" STREQUAL "")
        set(_x_macos_architectures ${CMAKE_OSX_ARCHITECTURES})
        list(REMOVE_DUPLICATES _x_macos_architectures)
        list(LENGTH _x_macos_architectures _x_macos_architecture_count)
        list(FIND _x_macos_architectures "x86_64" _x_macos_x86_64_index)
        list(FIND _x_macos_architectures "arm64" _x_macos_arm64_index)
        if(_x_macos_architecture_count EQUAL 2
           AND NOT _x_macos_x86_64_index EQUAL -1
           AND NOT _x_macos_arm64_index EQUAL -1)
            set(X_PROJECT_ARCH "universal2")
        elseif(_x_macos_architecture_count EQUAL 1)
            list(GET _x_macos_architectures 0 X_PROJECT_ARCH)
        else()
            list(JOIN _x_macos_architectures "-" X_PROJECT_ARCH)
        endif()
        unset(_x_macos_architectures)
        unset(_x_macos_architecture_count)
        unset(_x_macos_x86_64_index)
        unset(_x_macos_arm64_index)
    else()
        set(X_PROJECT_ARCH "${CMAKE_SYSTEM_PROCESSOR}")
    endif()
    add_compile_options(-Wno-deprecated-declarations)
    add_compile_options(-Wno-switch)
    set_source_files_properties(${X_MACOS_ICON} PROPERTIES MACOSX_PACKAGE_LOCATION "Resources")
endif()

configure_file("${PROJECT_SOURCE_DIR}/../LICENSE" "${PROJECT_SOURCE_DIR}/../res/license.txt" @ONLY)

if(NOT EXISTS "${PROJECT_SOURCE_DIR}/../res/readme.txt")
    configure_file("${PROJECT_SOURCE_DIR}/../README.md" "${PROJECT_SOURCE_DIR}/../res/readme.txt" @ONLY)
endif()

set(CPACK_INCLUDE_TOPLEVEL_DIRECTORY OFF)
set(CPACK_OUTPUT_FILE_PREFIX packages)
set(CPACK_RESOURCE_FILE_LICENSE "${PROJECT_SOURCE_DIR}/../res/license.txt")
set(CPACK_RESOURCE_FILE_README "${PROJECT_SOURCE_DIR}/../res/readme.txt")
file (STRINGS "${PROJECT_SOURCE_DIR}/../release_version.txt" CPACK_PACKAGE_VERSION)
set(CPACK_PACKAGE_NAME ${X_PROJECTNAME})
set(CPACK_PACKAGE_INSTALL_DIRECTORY ${X_PROJECTNAME})
set(CPACK_PACKAGE_INSTALL_REGISTRY_KEY ${X_PROJECTNAME})
set(CPACK_PACKAGE_VENDOR ${X_COMPANYNAME})
set(CPACK_PACKAGE_DESCRIPTION ${X_DESCRIPTION})
set(CPACK_PACKAGE_HOMEPAGE_URL ${X_HOMEPAGE})

if (WIN32)
    if(NOT DEFINED CPACK_SOURCE_GENERATOR)
        set(CPACK_SOURCE_GENERATOR "ZIP")
    endif()
    set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}_${X_PROJECT_OSNAME}_portable_${CPACK_PACKAGE_VERSION}_${X_PROJECT_ARCH}")
endif()

if (CMAKE_SYSTEM_NAME MATCHES "Linux")
    include(GNUInstallDirs)
    if(NOT DEFINED X_DEB_ARCH OR "${X_DEB_ARCH}" STREQUAL "")
        set(X_DEB_ARCH ${X_PROJECT_ARCH})

        # Standard mappings between CMake and Debian architectures.  A release
        # recipe may instead provide the native architecture reported by dpkg;
        # do not replace that package-manager-owned value with a processor
        # spelling inferred by CMake.
        if(X_PROJECT_ARCH STREQUAL "x86_64")
            set(X_DEB_ARCH "amd64")
        elseif(X_PROJECT_ARCH MATCHES "^i[3456]86$")
            set(X_DEB_ARCH "i386")
        elseif(X_PROJECT_ARCH MATCHES "^armv7")
            set(X_DEB_ARCH "armhf")
        elseif(X_PROJECT_ARCH STREQUAL "aarch64")
            set(X_DEB_ARCH "arm64")
        elseif(X_PROJECT_ARCH STREQUAL "ppc64le")
            set(X_DEB_ARCH "ppc64el")
        endif()
    endif()

    if(NOT DEFINED CPACK_SOURCE_GENERATOR)
        set(CPACK_SOURCE_GENERATOR "TGZ;DEB")
    endif()
    set(CPACK_GENERATOR "DEB;TGZ")
    set(CPACK_DEBIAN_PACKAGE_MAINTAINER ${X_MAINTAINER})
    set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "${X_DEB_ARCH}")
    set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}_${CPACK_PACKAGE_VERSION}_${X_PROJECT_OSNAME}_${X_DEB_ARCH}")
    # Debian's control Package field is a lowercase package identifier, not a
    # display name or output filename. Versions, OS labels, spaces and
    # underscores make the generated .deb invalid.
    string(TOLOWER "${CPACK_PACKAGE_NAME}" _x_debian_package_name)
    string(REGEX REPLACE "[^a-z0-9+.-]+" "-"
        _x_debian_package_name "${_x_debian_package_name}")
    string(REGEX REPLACE "^-+|-+$" ""
        _x_debian_package_name "${_x_debian_package_name}")
    if("${_x_debian_package_name}" STREQUAL ""
       OR NOT _x_debian_package_name MATCHES "^[a-z0-9][a-z0-9+.-]+$")
        message(FATAL_ERROR
            "Cannot derive a valid Debian package name from "
            "'${CPACK_PACKAGE_NAME}'")
    endif()
    set(CPACK_DEBIAN_PACKAGE_NAME "${_x_debian_package_name}")
    unset(_x_debian_package_name)
    message(STATUS CPACK_DEBIAN_PACKAGE_ARCHITECTURE: ${CPACK_DEBIAN_PACKAGE_ARCHITECTURE})
    message(STATUS CPACK_DEBIAN_PACKAGE_NAME: ${CPACK_DEBIAN_PACKAGE_NAME})
    #set(CPACK_DEBIAN_PACKAGE_SECTION ${X_SECTION})

    # dpkg-shlibdeps is authoritative when enabled: it follows the linked ELF
    # symbols through the build host's Debian symbols/shlibs database, including
    # ABI transitions such as Debian 13's t64 Qt package names.  Keep any
    # caller-supplied non-library dependencies, but do not append guessed Qt
    # package names in that mode.
    if (NOT CPACK_DEBIAN_PACKAGE_SHLIBDEPS)
        # Qt5
        if (NOT "${Qt5Core_VERSION}" STREQUAL "")
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
    endif()

    string(REPLACE ";" ", " CPACK_DEBIAN_PACKAGE_DEPENDS "${X_DEBIAN_PACKAGE_DEPENDS}")
    message(STATUS CPACK_DEBIAN_PACKAGE_DEPENDS: ${CPACK_DEBIAN_PACKAGE_DEPENDS})

    # CPack projects can opt in to a policy copyright without teaching this
    # shared helper any project-specific source-tree layout.  Debian requires
    # this exact lowercase package directory and uncompressed filename.
    if(DEFINED X_DEBIAN_COPYRIGHT_FILE
       AND NOT "${X_DEBIAN_COPYRIGHT_FILE}" STREQUAL "")
        get_filename_component(_x_debian_copyright
            "${X_DEBIAN_COPYRIGHT_FILE}" ABSOLUTE
            BASE_DIR "${CMAKE_BINARY_DIR}")
        if(NOT EXISTS "${_x_debian_copyright}"
           OR IS_DIRECTORY "${_x_debian_copyright}"
           OR IS_SYMLINK "${_x_debian_copyright}")
            message(FATAL_ERROR
                "X_DEBIAN_COPYRIGHT_FILE must name an existing ordinary file: "
                "${_x_debian_copyright}")
        endif()
        install(FILES "${_x_debian_copyright}"
            DESTINATION
                "${CMAKE_INSTALL_DATAROOTDIR}/doc/${CPACK_DEBIAN_PACKAGE_NAME}"
            RENAME "copyright")
        unset(_x_debian_copyright)
    endif()
endif()

if(APPLE)
    configure_file("${X_MACOS_INFO_PLIST_IN}" "${X_MACOS_INFO_PLIST}" @ONLY)

    set(CPACK_GENERATOR "Bundle;productbuild;ZIP")
    set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}_${CPACK_PACKAGE_VERSION}_${X_PROJECT_OSNAME}_${X_PROJECT_ARCH}")
    set(CPACK_BUNDLE_NAME ${X_PROJECTNAME})
    set(CPACK_BUNDLE_ICON ${X_MACOS_ICON})
    set(CPACK_BUNDLE_PLIST "${X_MACOS_INFO_PLIST}")
    set(CPACK_PRODUCTBUILD_IDENTIFIER ${MACOSX_BUNDLE_GUI_IDENTIFIER})
endif()

include(CPack)

if(WIN32)
    configure_file("${X_WINDOWS_RESOURCE_RC_IN}" "${X_WINDOWS_RESOURCE_RC}" @ONLY)
    configure_file("${X_WINDOWS_RESOURCE_ICON_RC_IN}" "${X_WINDOWS_RESOURCE_ICON_RC}" @ONLY)
endif()
