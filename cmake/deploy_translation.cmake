function(deploy_install_directory)
    set(options)
    set(oneValueArgs SOURCE_DIR INSTALL_DESTINATION WINDOWS_APPDATA_SUBDIR)
    set(multiValueArgs)
    cmake_parse_arguments(DEPLOY "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(NOT DEPLOY_SOURCE_DIR)
        message(WARNING "deploy_install_directory: SOURCE_DIR is empty.")
        return()
    endif()

    if(NOT EXISTS "${DEPLOY_SOURCE_DIR}")
        message(WARNING "deploy_install_directory: SOURCE_DIR does not exist: ${DEPLOY_SOURCE_DIR}")
        return()
    endif()

    if(NOT DEPLOY_INSTALL_DESTINATION)
        message(WARNING "deploy_install_directory: INSTALL_DESTINATION is empty.")
        return()
    endif()

    install(DIRECTORY "${DEPLOY_SOURCE_DIR}/" DESTINATION "${DEPLOY_INSTALL_DESTINATION}")

    if(WIN32 AND DEPLOY_WINDOWS_APPDATA_SUBDIR)
        set(_deploy_install_code "string(FIND \"\${CMAKE_INSTALL_PREFIX}\" \"_CPack_Packages\" _deploy_cpack_index)\n")
        string(APPEND _deploy_install_code "if(_deploy_cpack_index EQUAL -1)\n")
        string(APPEND _deploy_install_code "    set(_deploy_source_dir \"\${CMAKE_INSTALL_PREFIX}/${DEPLOY_INSTALL_DESTINATION}\")\n")
        string(APPEND _deploy_install_code "    if(EXISTS \"\${_deploy_source_dir}\")\n")
        string(APPEND _deploy_install_code "        if(NOT \"\$ENV{APPDATA}\" STREQUAL \"\")\n")
        string(APPEND _deploy_install_code "            file(TO_CMAKE_PATH \"\$ENV{APPDATA}\" _deploy_appdata_dir)\n")
        string(APPEND _deploy_install_code "            set(_deploy_target_dir \"\${_deploy_appdata_dir}/${DEPLOY_WINDOWS_APPDATA_SUBDIR}/${DEPLOY_INSTALL_DESTINATION}\")\n")
        string(APPEND _deploy_install_code "            file(MAKE_DIRECTORY \"\${_deploy_target_dir}\")\n")
        string(APPEND _deploy_install_code "            file(COPY \"\${_deploy_source_dir}/\" DESTINATION \"\${_deploy_target_dir}\")\n")
        string(APPEND _deploy_install_code "        endif()\n")
        string(APPEND _deploy_install_code "    endif()\n")
        string(APPEND _deploy_install_code "endif()\n")

        install(CODE "${_deploy_install_code}")
    endif()
endfunction()

function(deploy_create_missing_ts_files)
    set(options)
    set(oneValueArgs LUPDATE_EXECUTABLE SOURCE_DIR)
    set(multiValueArgs SOURCE_DIRS TS_FILES LUPDATE_HINTS LUPDATE_OPTIONS)
    cmake_parse_arguments(DEPLOY_CREATE_TS "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(DEPLOY_CREATE_TS_SOURCE_DIR)
        list(APPEND DEPLOY_CREATE_TS_SOURCE_DIRS "${DEPLOY_CREATE_TS_SOURCE_DIR}")
    endif()

    if(NOT DEPLOY_CREATE_TS_SOURCE_DIRS)
        set(DEPLOY_CREATE_TS_SOURCE_DIRS "${CMAKE_CURRENT_SOURCE_DIR}")
    endif()

    if(NOT DEPLOY_CREATE_TS_TS_FILES)
        message(WARNING "deploy_create_missing_ts_files: TS_FILES is empty.")
        return()
    endif()

    set(_deploy_missing_ts_files "")
    foreach(_deploy_ts_file ${DEPLOY_CREATE_TS_TS_FILES})
        if(NOT EXISTS "${_deploy_ts_file}")
            list(APPEND _deploy_missing_ts_files "${_deploy_ts_file}")
        endif()
    endforeach()

    if(NOT _deploy_missing_ts_files)
        return()
    endif()

    foreach(_deploy_source_dir ${DEPLOY_CREATE_TS_SOURCE_DIRS})
        if(NOT EXISTS "${_deploy_source_dir}")
            message(FATAL_ERROR "deploy_create_missing_ts_files: SOURCE_DIR does not exist: ${_deploy_source_dir}")
        endif()
    endforeach()

    set(_deploy_lupdate_executable "")
    if(DEPLOY_CREATE_TS_LUPDATE_EXECUTABLE)
        set(_deploy_lupdate_executable "${DEPLOY_CREATE_TS_LUPDATE_EXECUTABLE}")
    endif()

    if(NOT _deploy_lupdate_executable)
        foreach(_deploy_lupdate_target Qt6::lupdate Qt5::lupdate)
            if(TARGET ${_deploy_lupdate_target})
                get_target_property(_deploy_lupdate_target_location ${_deploy_lupdate_target} IMPORTED_LOCATION)
                if(_deploy_lupdate_target_location)
                    set(_deploy_lupdate_executable "${_deploy_lupdate_target_location}")
                    break()
                endif()
            endif()
        endforeach()
    endif()

    if(NOT _deploy_lupdate_executable)
        set(_deploy_lupdate_hints ${DEPLOY_CREATE_TS_LUPDATE_HINTS})
        if(CMAKE_PREFIX_PATH)
            foreach(_deploy_qt_prefix_path ${CMAKE_PREFIX_PATH})
                list(APPEND _deploy_lupdate_hints "${_deploy_qt_prefix_path}/bin")
            endforeach()
        endif()

        find_program(_deploy_lupdate_program
            NAMES lupdate lupdate.exe
            HINTS ${_deploy_lupdate_hints}
        )

        if(_deploy_lupdate_program)
            set(_deploy_lupdate_executable "${_deploy_lupdate_program}")
        endif()
    endif()

    if(NOT _deploy_lupdate_executable)
        string(REPLACE ";" "\n  " _deploy_missing_ts_message "${_deploy_missing_ts_files}")
        message(FATAL_ERROR
            "lupdate was not found, and missing translation source files cannot be generated:\n"
            "  ${_deploy_missing_ts_message}"
        )
    endif()

    foreach(_deploy_ts_file ${_deploy_missing_ts_files})
        get_filename_component(_deploy_ts_dir "${_deploy_ts_file}" DIRECTORY)
        file(MAKE_DIRECTORY "${_deploy_ts_dir}")
    endforeach()

    execute_process(
        COMMAND "${_deploy_lupdate_executable}"
            -recursive
            ${DEPLOY_CREATE_TS_LUPDATE_OPTIONS}
            ${DEPLOY_CREATE_TS_SOURCE_DIRS}
            -ts ${_deploy_missing_ts_files}
        RESULT_VARIABLE _deploy_lupdate_result
        OUTPUT_VARIABLE _deploy_lupdate_output
        ERROR_VARIABLE _deploy_lupdate_error
    )

    if(NOT _deploy_lupdate_result EQUAL 0)
        message(FATAL_ERROR
            "Failed to create missing translation source files.\n"
            "${_deploy_lupdate_output}\n"
            "${_deploy_lupdate_error}"
        )
    endif()
endfunction()

function(deploy_add_translations)
    set(options ADD_TO_ALL)
    set(oneValueArgs TARGET_NAME INSTALL_DESTINATION OUTPUT_DIR WINDOWS_APPDATA_SUBDIR SOURCE_DIR LUPDATE_EXECUTABLE)
    set(multiValueArgs TS_FILES LRELEASE_HINTS SOURCE_DIRS LUPDATE_HINTS LUPDATE_OPTIONS)
    cmake_parse_arguments(DEPLOY "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(NOT DEPLOY_TARGET_NAME)
        set(DEPLOY_TARGET_NAME translations)
    endif()

    if(NOT DEPLOY_INSTALL_DESTINATION)
        set(DEPLOY_INSTALL_DESTINATION translations)
    endif()

    if(NOT DEPLOY_OUTPUT_DIR)
        set(DEPLOY_OUTPUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/translations")
    endif()

    if(NOT DEPLOY_TS_FILES)
        message(WARNING "deploy_add_translations: TS_FILES is empty.")
        return()
    endif()

    set(_deploy_create_ts_args
        TS_FILES ${DEPLOY_TS_FILES}
        SOURCE_DIRS ${DEPLOY_SOURCE_DIRS}
        LUPDATE_HINTS ${DEPLOY_LUPDATE_HINTS}
        LUPDATE_OPTIONS ${DEPLOY_LUPDATE_OPTIONS}
    )

    if(DEPLOY_SOURCE_DIR)
        list(APPEND _deploy_create_ts_args SOURCE_DIR "${DEPLOY_SOURCE_DIR}")
    endif()

    if(DEPLOY_LUPDATE_EXECUTABLE)
        list(APPEND _deploy_create_ts_args LUPDATE_EXECUTABLE "${DEPLOY_LUPDATE_EXECUTABLE}")
    endif()

    deploy_create_missing_ts_files(${_deploy_create_ts_args})

    set(_lrelease_hints ${DEPLOY_LRELEASE_HINTS})
    if(CMAKE_PREFIX_PATH)
        set(_qt_prefix_paths ${CMAKE_PREFIX_PATH})
        list(GET _qt_prefix_paths 0 _qt_prefix_first)
        list(APPEND _lrelease_hints "${_qt_prefix_first}/bin")
    endif()

    find_program(_deploy_lrelease_executable lrelease HINTS ${_lrelease_hints})

    if(NOT _deploy_lrelease_executable)
        message(WARNING "lrelease was not found. Translation files will not be generated.")
        return()
    endif()

    set(_deploy_qm_files "")
    foreach(_deploy_ts_file ${DEPLOY_TS_FILES})
        get_filename_component(_deploy_ts_name "${_deploy_ts_file}" NAME_WE)
        set(_deploy_qm_file "${DEPLOY_OUTPUT_DIR}/${_deploy_ts_name}.qm")

        add_custom_command(
            OUTPUT "${_deploy_qm_file}"
            COMMAND ${CMAKE_COMMAND} -E make_directory "${DEPLOY_OUTPUT_DIR}"
            COMMAND "${_deploy_lrelease_executable}" "${_deploy_ts_file}" -qm "${_deploy_qm_file}"
            DEPENDS "${_deploy_ts_file}"
            VERBATIM
        )

        list(APPEND _deploy_qm_files "${_deploy_qm_file}")
    endforeach()

    if(_deploy_qm_files)
        if(DEPLOY_ADD_TO_ALL)
            add_custom_target(${DEPLOY_TARGET_NAME} ALL DEPENDS ${_deploy_qm_files})
        else()
            add_custom_target(${DEPLOY_TARGET_NAME} DEPENDS ${_deploy_qm_files})
        endif()

        install(FILES ${_deploy_qm_files} DESTINATION ${DEPLOY_INSTALL_DESTINATION})

        if(WIN32 AND DEPLOY_WINDOWS_APPDATA_SUBDIR)
            set(_deploy_install_code "string(FIND \"\${CMAKE_INSTALL_PREFIX}\" \"_CPack_Packages\" _deploy_cpack_index)\n")
            string(APPEND _deploy_install_code "if(_deploy_cpack_index EQUAL -1)\n")
            string(APPEND _deploy_install_code "    set(_deploy_source_dir \"\${CMAKE_INSTALL_PREFIX}/${DEPLOY_INSTALL_DESTINATION}\")\n")
            string(APPEND _deploy_install_code "    if(EXISTS \"\${_deploy_source_dir}\")\n")
            string(APPEND _deploy_install_code "        if(NOT \"\$ENV{APPDATA}\" STREQUAL \"\")\n")
            string(APPEND _deploy_install_code "            file(TO_CMAKE_PATH \"\$ENV{APPDATA}\" _deploy_appdata_dir)\n")
            string(APPEND _deploy_install_code "            set(_deploy_target_dir \"\${_deploy_appdata_dir}/${DEPLOY_WINDOWS_APPDATA_SUBDIR}/${DEPLOY_INSTALL_DESTINATION}\")\n")
            string(APPEND _deploy_install_code "            file(MAKE_DIRECTORY \"\${_deploy_target_dir}\")\n")
            string(APPEND _deploy_install_code "            file(COPY \"\${_deploy_source_dir}/\" DESTINATION \"\${_deploy_target_dir}\")\n")
            string(APPEND _deploy_install_code "        endif()\n")
            string(APPEND _deploy_install_code "    endif()\n")
            string(APPEND _deploy_install_code "endif()\n")

            install(CODE "${_deploy_install_code}")
        endif()

        set(${DEPLOY_TARGET_NAME}_QM_FILES ${_deploy_qm_files} PARENT_SCOPE)
    endif()
endfunction()
