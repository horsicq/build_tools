message("Checking macdeployqt for ${PROJECT_NAME}")

if(TARGET ${PROJECT_NAME})
    get_target_property(_target_dir ${PROJECT_NAME} SOURCE_DIR)
    
    if("${_target_dir}" STREQUAL "${CMAKE_CURRENT_SOURCE_DIR}")
        
        find_program(MACDEPLOYQT NAMES macdeployqt)
        if(MACDEPLOYQT)
            add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
                COMMAND ${MACDEPLOYQT} "$<TARGET_BUNDLE_DIR:${PROJECT_NAME}>"
                COMMENT "Running macdeployqt on ${PROJECT_NAME}"
            )
        else()
            message(WARNING "macdeployqt not found; the app bundle will not be deployable")
        endif()
        
    endif()
endif()