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
