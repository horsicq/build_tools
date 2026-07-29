function(x_sanitize_linux_package_component
         input_value fallback_value output_variable)
    string(TOLOWER "${input_value}" _x_package_component)
    string(REGEX REPLACE "[^a-z0-9.+-]+" "-"
        _x_package_component "${_x_package_component}")
    string(REGEX REPLACE "-+" "-"
        _x_package_component "${_x_package_component}")
    string(REGEX REPLACE "^[.+-]+|[.+-]+$" ""
        _x_package_component "${_x_package_component}")
    if("${_x_package_component}" STREQUAL "")
        set(_x_package_component "${fallback_value}")
    endif()
    string(LENGTH "${_x_package_component}" _x_package_component_length)
    if(_x_package_component_length GREATER 32)
        message(FATAL_ERROR
            "Sanitized Linux package component exceeds 32 characters: "
            "'${_x_package_component}'")
    endif()
    set("${output_variable}" "${_x_package_component}" PARENT_SCOPE)
endfunction()

function(x_make_linux_package_os_label
         raw_id raw_version output_label output_id output_version)
    x_sanitize_linux_package_component(
        "${raw_id}" "linux" _x_package_id)
    x_sanitize_linux_package_component(
        "${raw_version}" "" _x_package_version)

    set(_x_package_label "${_x_package_id}")
    if(NOT "${_x_package_version}" STREQUAL "")
        string(APPEND _x_package_label "_${_x_package_version}")
    endif()
    if(NOT _x_package_label MATCHES
       "^[a-z0-9][a-z0-9.+-]*(_[a-z0-9][a-z0-9.+-]*)?$")
        message(FATAL_ERROR
            "Linux package OS label is not filename-safe: "
            "'${_x_package_label}'")
    endif()

    set("${output_label}" "${_x_package_label}" PARENT_SCOPE)
    set("${output_id}" "${_x_package_id}" PARENT_SCOPE)
    set("${output_version}" "${_x_package_version}" PARENT_SCOPE)
endfunction()

function(x_read_os_release_value os_release_file key output_variable)
    set(_x_os_release_value "")
    if(EXISTS "${os_release_file}")
        file(STRINGS "${os_release_file}" _x_os_release_lines
            LIMIT_COUNT 1
            ENCODING UTF-8
            REGEX "^${key}=")
        list(LENGTH _x_os_release_lines _x_os_release_line_count)
        if(_x_os_release_line_count EQUAL 1)
            list(GET _x_os_release_lines 0 _x_os_release_value)
            string(REGEX REPLACE "^[^=]*=" ""
                _x_os_release_value "${_x_os_release_value}")
            string(REGEX REPLACE "^\"(.*)\"$" "\\1"
                _x_os_release_value "${_x_os_release_value}")
            string(REGEX REPLACE "^'(.*)'$" "\\1"
                _x_os_release_value "${_x_os_release_value}")
        endif()
    endif()
    set("${output_variable}" "${_x_os_release_value}" PARENT_SCOPE)
endfunction()

function(x_get_linux_package_os_label
         os_release_file output_label output_id output_version)
    x_read_os_release_value(
        "${os_release_file}" "ID" _x_raw_os_id)
    x_read_os_release_value(
        "${os_release_file}" "VERSION_ID" _x_raw_os_version)
    x_make_linux_package_os_label(
        "${_x_raw_os_id}"
        "${_x_raw_os_version}"
        _x_package_label
        _x_package_id
        _x_package_version)

    set("${output_label}" "${_x_package_label}" PARENT_SCOPE)
    set("${output_id}" "${_x_package_id}" PARENT_SCOPE)
    set("${output_version}" "${_x_package_version}" PARENT_SCOPE)
endfunction()
