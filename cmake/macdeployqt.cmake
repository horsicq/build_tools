message("macdeployqt")

find_program(MACDEPLOYQT NAMES macdeployqt)
if(MACDEPLOYQT)
    add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${MACDEPLOYQT} "$<TARGET_BUNDLE_DIR:${PROJECT_NAME}>"
        COMMENT "Macdeployqt the executable"
    )
else()
    if(XVMPUNPACKER_RELEASE_BUILD)
        message(FATAL_ERROR
            "macdeployqt is required for an XVMPUnpacker release build")
    else()
        message(WARNING
            "macdeployqt not found; the build-tree app is not deployable")
    endif()
endif()
