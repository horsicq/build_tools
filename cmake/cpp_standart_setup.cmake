include_guard(GLOBAL)

include(GNUInstallDirs)

# Enable Qt auto tools if not already configured
if(NOT DEFINED CMAKE_AUTOUIC)
    set(CMAKE_AUTOUIC ON)
endif()
if(NOT DEFINED CMAKE_AUTOMOC)
    set(CMAKE_AUTOMOC ON)
endif()
if(NOT DEFINED CMAKE_AUTORCC)
    set(CMAKE_AUTORCC ON)
endif()

# Respect existing C++ standard; default to 14 if not set
if(NOT DEFINED CMAKE_CXX_STANDARD)
    set(CMAKE_CXX_STANDARD 14)
endif()
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

if(WIN32)
    if (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
        foreach(flag_var IN ITEMS CMAKE_EXE_LINKER_FLAGS CMAKE_MODULE_LINKER_FLAGS CMAKE_SHARED_LINKER_FLAGS)
            if(NOT ${flag_var} MATCHES "/MANIFEST:NO")
                set(${flag_var} "${${flag_var}} /MANIFEST:NO")
            endif()
        endforeach()
    endif()
endif()

if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    message(STATUS "Using GNU Compiler")
    #TODO
elseif (CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
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
endif()

if(NOT DEFINED X_RESOURCES)
    if(WIN32)
        set(X_RESOURCES "./")
    elseif(APPLE)
        set(X_RESOURCES "./${PROJECT_NAME}.app/Contents/Resources")
    else()
        set(X_RESOURCES ${CMAKE_INSTALL_LIBDIR}/${PROJECT_NAME})
    endif()
endif()

