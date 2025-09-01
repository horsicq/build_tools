include_guard(GLOBAL)

message(STATUS "Create translation")

# Determine sources/dirs for lupdate. Prefer project sources if available,
# otherwise scan current source dir.
set(_LUPDATE_SOURCES)
if(DEFINED PROJECT_SOURCES)
    set(_LUPDATE_SOURCES ${PROJECT_SOURCES})
else()
    set(_LUPDATE_SOURCES ${CMAKE_CURRENT_SOURCE_DIR})
endif()

unset(QM_FILES)

if(${QT_VERSION_MAJOR} EQUAL 5)
    if(${QT_VERSION} VERSION_GREATER_EQUAL 5.6.0)
        if(COMMAND qt5_create_translation)
            qt5_create_translation(QM_FILES ${_LUPDATE_SOURCES} ${TS_FILES} OPTIONS -locations none)
        elseif(COMMAND qt5_add_translation)
            qt5_add_translation(QM_FILES ${TS_FILES})
        else()
            message(WARNING "No suitable Qt5 translation command available")
        endif()
    endif()
elseif(${QT_VERSION_MAJOR} GREATER_EQUAL 6)
    if(COMMAND qt6_create_translation)
        qt6_create_translation(QM_FILES ${_LUPDATE_SOURCES} ${TS_FILES} OPTIONS -locations none)
    elseif(COMMAND qt_create_translation)
        qt_create_translation(QM_FILES ${_LUPDATE_SOURCES} ${TS_FILES} OPTIONS -locations none)
    elseif(COMMAND qt6_add_translation)
        qt6_add_translation(QM_FILES ${TS_FILES})
    elseif(COMMAND qt_add_translation)
        qt_add_translation(QM_FILES ${TS_FILES})
    else()
        message(WARNING "No suitable Qt6 translation command available")
    endif()
endif()

# Add a phony target only once and only if we have outputs
if(QM_FILES)
    if(NOT TARGET translations)
        add_custom_target(translations DEPENDS ${QM_FILES})
    endif()
endif()

if (DEFINED X_RESOURCES AND QM_FILES)
    install (FILES ${QM_FILES} DESTINATION "${X_RESOURCES}/lang" OPTIONAL)
endif()
