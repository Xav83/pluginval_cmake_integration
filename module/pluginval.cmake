function(pluginval_display_version)
    # Runs the command to get the pluginval version
    execute_process(COMMAND pluginval --version
        OUTPUT_VARIABLE PLUGINVAL_VERSION_RAW_OUTPUT
    )

    # Extracts the version from the output of the command run before
    string(SUBSTRING ${PLUGINVAL_VERSION_RAW_OUTPUT} 12 -1 PLUGINVAL_VERSION_OUTPUT)
    string(STRIP ${PLUGINVAL_VERSION_OUTPUT} PLUGINVAL_VERSION_OUTPUT)

    message(STATUS "Plugin version output : ${PLUGINVAL_VERSION_OUTPUT}")
endfunction()
