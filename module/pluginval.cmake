function(pluginval_version output_var)
    # Runs the command to get the pluginval version
    execute_process(COMMAND pluginval --version
        OUTPUT_VARIABLE PLUGINVAL_VERSION_RAW_OUTPUT
    )

    # Extracts the version from the output of the command run before
    string(SUBSTRING ${PLUGINVAL_VERSION_RAW_OUTPUT} 12 -1 PLUGINVAL_VERSION_OUTPUT)
    string(STRIP ${PLUGINVAL_VERSION_OUTPUT} PLUGINVAL_VERSION_OUTPUT)

    set(${output_var} ${PLUGINVAL_VERSION_OUTPUT} PARENT_SCOPE)
endfunction()


function(pluginval_display_version)
    pluginval_version(PLUGINVAL_VERSION)
    message(STATUS "Pluginval version detected : ${PLUGINVAL_VERSION}")
endfunction()

function(pluginval_minimum_required)
    set(options FATAL_ERROR)
    set(oneValueArgs)
    set(multiValueArgs VERSION)
    cmake_parse_arguments(PLUGINVAL_MINIMUM_REQUIRED "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    ## If zero version are passed
    if(NOT DEFINED PLUGINVAL_MINIMUM_REQUIRED_VERSION)
        message(FATAL_ERROR "No VERSION passed to pluginval_minimum_required. Please add one or a range of versions")
    endif()

    list(LENGTH PLUGINVAL_MINIMUM_REQUIRED_VERSION NUMBER_OF_VERSIONS_INPUT)

    ## If more than three versions are passed
    if(${NUMBER_OF_VERSIONS_INPUT} GREATER_EQUAL 3)
        message(FATAL_ERROR "Too much versions(${NUMBER_OF_VERSIONS_INPUT}) given. You can only pass one or a range of versions to pluginval_minimum_required.")
    endif()

    # Get the pluginval actual version
    pluginval_version(PLUGINVAL_ACTUAL_VERSION)

    # Sets the warning level when amismatch in the version is found
    set(WARNING_LEVEL WARNING)
    if(PLUGINVAL_MINIMUM_REQUIRED_FATAL_ERROR)
        set(WARNING_LEVEL FATAL_ERROR)
    endif()

    ## If one version is passed
    if(${NUMBER_OF_VERSIONS_INPUT} EQUAL 1)
        # Gets the expected minimum version from the user
        list(GET PLUGINVAL_MINIMUM_REQUIRED_VERSION 0 MINIMUM_VERSION_EXPECTED)

        # Displays a message if the version installed is older that the one expected
        if(MINIMUM_VERSION_EXPECTED VERSION_GREATER PLUGINVAL_ACTUAL_VERSION)
            message(${WARNING_LEVEL} "The expected version (${MINIMUM_VERSION_EXPECTED}) of pluginval is younger than the one installed (${PLUGINVAL_ACTUAL_VERSION})")
        endif()
    endif()

    ## If two versions are passed
    if(${NUMBER_OF_VERSIONS_INPUT} EQUAL 2)
        # Gets the expected versions range from the user
        list(GET PLUGINVAL_MINIMUM_REQUIRED_VERSION 0 MINIMUM_VERSION_EXPECTED)
        list(GET PLUGINVAL_MINIMUM_REQUIRED_VERSION 1 MAXIMAL_VERSION_EXPECTED)

        if(MINIMUM_VERSION_EXPECTED VERSION_GREATER MAXIMAL_VERSION_EXPECTED)
            message(FATAL_ERROR "The range of versions is reversed (the first one is greater than the second one - \"VERSION ${MINIMUM_VERSION_EXPECTED} ${MAXIMAL_VERSION_EXPECTED}\").")
        endif()

        if(MINIMUM_VERSION_EXPECTED VERSION_EQUAL MAXIMAL_VERSION_EXPECTED)
            message(WARNING "The two versions given to pluginval_minimum_required are the same. You may want to only pass one minimal version instead.")
        endif()

        if(MINIMUM_VERSION_EXPECTED VERSION_GREATER PLUGINVAL_ACTUAL_VERSION)
            message(${WARNING_LEVEL} "The minimum expected version (${MINIMUM_VERSION_EXPECTED}) of pluginval is younger than the one installed (${PLUGINVAL_ACTUAL_VERSION})")
        endif()

        if(PLUGINVAL_ACTUAL_VERSION VERSION_GREATER MAXIMAL_VERSION_EXPECTED)
            message(${WARNING_LEVEL} "The maximum expected version (${MINIMUM_VERSION_EXPECTED}) of pluginval is older than the one installed (${PLUGINVAL_ACTUAL_VERSION})")
        endif()
    endif()
endfunction()
