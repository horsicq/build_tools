message(STATUS qt_version_${QT_VERSION_MAJOR})
if (WIN32)
    string(REPLACE "\\" "/" CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH})
    # Qt5
    if (NOT "${Qt5Core_VERSION}" STREQUAL "")
        install (FILES "${CMAKE_PREFIX_PATH}/bin/Qt5Core.dll" DESTINATION "./" OPTIONAL)
    endif()
    if (NOT "${Qt5Gui_VERSION}" STREQUAL "")
        install (FILES "${CMAKE_PREFIX_PATH}/bin/Qt5Gui.dll" DESTINATION "./" OPTIONAL)
        install (FILES "${CMAKE_PREFIX_PATH}/plugins/platforms/qwindows.dll" DESTINATION "platforms" OPTIONAL)
        install (FILES "${CMAKE_PREFIX_PATH}/plugins/imageformats/qjpeg.dll" DESTINATION "imageformats" OPTIONAL)
        install (FILES "${CMAKE_PREFIX_PATH}/plugins/imageformats/qtiff.dll" DESTINATION "imageformats" OPTIONAL)
        install (FILES "${CMAKE_PREFIX_PATH}/plugins/imageformats/qico.dll" DESTINATION "imageformats" OPTIONAL)
        install (FILES "${CMAKE_PREFIX_PATH}/plugins/imageformats/qgif.dll" DESTINATION "imageformats" OPTIONAL)
    endif()
    if (NOT "${Qt5Widgets_VERSION}" STREQUAL "")
        install (FILES "${CMAKE_PREFIX_PATH}/bin/Qt5Widgets.dll" DESTINATION "./" OPTIONAL)
    endif()
    if (NOT "${Qt5OpenGL_VERSION}" STREQUAL "")
        install (FILES "${CMAKE_PREFIX_PATH}/bin/Qt5OpenGL.dll" DESTINATION "./" OPTIONAL)
    endif()
    if (NOT "${Qt5Svg_VERSION}" STREQUAL "")
        install (FILES "${CMAKE_PREFIX_PATH}/bin/Qt5Svg.dll" DESTINATION "./" OPTIONAL)
    endif()
    if (NOT "${Qt5Sql_VERSION}" STREQUAL "")
        install (FILES "${CMAKE_PREFIX_PATH}/bin/Qt5Sql.dll" DESTINATION "./" OPTIONAL)
        install (FILES "${CMAKE_PREFIX_PATH}/plugins/sqldrivers/qsqlite.dll" DESTINATION sqldrivers OPTIONAL)
    endif()
    if (NOT "${Qt5Network_VERSION}" STREQUAL "")
        install (FILES "${CMAKE_PREFIX_PATH}/bin/Qt5Network.dll" DESTINATION "./" OPTIONAL)
    endif()
    if (NOT "${Qt5Script_VERSION}" STREQUAL "")
        install (FILES "${CMAKE_PREFIX_PATH}/bin/Qt5Script.dll" DESTINATION "./" OPTIONAL)
    endif()
    if (NOT "${Qt5ScriptTools_VERSION}" STREQUAL "")
        install (FILES "${CMAKE_PREFIX_PATH}/bin/Qt5ScriptTools.dll" DESTINATION "./" OPTIONAL)
    endif()
    #Qt6
    if (NOT "${Qt6Core_VERSION}" STREQUAL "")
        install (FILES "${CMAKE_PREFIX_PATH}/bin/Qt6Core.dll" DESTINATION "./" OPTIONAL)
    endif()
    if (NOT "${Qt6Gui_VERSION}" STREQUAL "")
        install (FILES "${CMAKE_PREFIX_PATH}/bin/Qt6Gui.dll" DESTINATION "./" OPTIONAL)
        install (FILES "${CMAKE_PREFIX_PATH}/plugins/platforms/qwindows.dll" DESTINATION "platforms" OPTIONAL)
        install (FILES "${CMAKE_PREFIX_PATH}/plugins/imageformats/qjpeg.dll" DESTINATION "imageformats" OPTIONAL)
        install (FILES "${CMAKE_PREFIX_PATH}/plugins/imageformats/qsvg.dll" DESTINATION "imageformats" OPTIONAL)
        install (FILES "${CMAKE_PREFIX_PATH}/plugins/imageformats/qico.dll" DESTINATION "imageformats" OPTIONAL)
        install (FILES "${CMAKE_PREFIX_PATH}/plugins/imageformats/qgif.dll" DESTINATION "imageformats" OPTIONAL)
    endif()
    if (NOT "${Qt6Widgets_VERSION}" STREQUAL "")
        install (FILES "${CMAKE_PREFIX_PATH}/bin/Qt6Widgets.dll" DESTINATION "./" OPTIONAL)
    endif()
    if (NOT "${Qt6OpenGL_VERSION}" STREQUAL "")
        install (FILES "${CMAKE_PREFIX_PATH}/bin/Qt6OpenGL.dll" DESTINATION "./" OPTIONAL)
    endif()
    if (NOT "${Qt6Svg_VERSION}" STREQUAL "")
        install (FILES "${CMAKE_PREFIX_PATH}/bin/Qt6Svg.dll" DESTINATION "./" OPTIONAL)
    endif()
    if (NOT "${Qt6Sql_VERSION}" STREQUAL "")
        install (FILES "${CMAKE_PREFIX_PATH}/bin/Qt6Sql.dll" DESTINATION "./")
        install (FILES "${CMAKE_PREFIX_PATH}/plugins/sqldrivers/qsqlite.dll" DESTINATION "sqldrivers" OPTIONAL)
    endif()
    if (NOT "${Qt6Network_VERSION}" STREQUAL "")
        install (FILES "${CMAKE_PREFIX_PATH}/bin/Qt6Network.dll" DESTINATION "./" OPTIONAL)
    endif()
    if (NOT "${Qt6Qml_VERSION}" STREQUAL "")
        install (FILES "${CMAKE_PREFIX_PATH}/bin/Qt6Qml.dll" DESTINATION "./" OPTIONAL)
    endif()
endif()
