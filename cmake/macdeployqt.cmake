message("macdeployqt")

find_program(MACDEPLOYQT NAMES macdeployqt)
if(NOT MACDEPLOYQT)
    message(FATAL_ERROR "macdepolyqt not found. Please install Qt tools")
endif()
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
    COMMAND ${MACDEPLOYQT} "$<TARGET_BUNDLE_DIR:${PROJECT_NAME}>"
    COMMENT "Macdeployqt the executable"
)
