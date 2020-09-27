set(PLUGINVAL_LOCATION
    ""
    CACHE PATH "Location of pluginval suggested by the user")

function(pluginval_is_installed output_var)
  unset(PLUGINVAL_EXECUTABLE CACHE)
  find_program(
    PLUGINVAL_EXECUTABLE
    NAMES pluginval pluginval.exe
    HINTS ${PLUGINVAL_LOCATION} C:/ProgramData/chocolatey/bin/pluginval
    DOC "PluginVal executable string")

  if(NOT PLUGINVAL_EXECUTABLE)
    set(${output_var}
        FALSE
        PARENT_SCOPE)
  else()
    set(${output_var}
        TRUE
        PARENT_SCOPE)
  endif()
endfunction()

function(pluginval_version output_var)
  pluginval_is_installed(IS_PLUGINVAL_INSTALLED)
  if(NOT ${IS_PLUGINVAL_INSTALLED})
    message(
      FATAL_ERROR
        "Pluginval must be installed on the machine! You can use one of the installation instruction here -> https://github.com/Tracktion/pluginval#installation"
    )
  endif()

  # Runs the command to get the pluginval version
  execute_process(COMMAND pluginval --version
                  OUTPUT_VARIABLE PLUGINVAL_VERSION_RAW_OUTPUT)

  # Extracts the version from the output of the command run before
  string(SUBSTRING ${PLUGINVAL_VERSION_RAW_OUTPUT} 12 -1
                   PLUGINVAL_VERSION_OUTPUT)
  string(STRIP ${PLUGINVAL_VERSION_OUTPUT} PLUGINVAL_VERSION_OUTPUT)

  set(${output_var}
      ${PLUGINVAL_VERSION_OUTPUT}
      PARENT_SCOPE)
endfunction()

function(pluginval_display_version)
  pluginval_version(PLUGINVAL_VERSION)
  message(STATUS "Pluginval version detected : ${PLUGINVAL_VERSION}")
endfunction()

function(pluginval_minimum_required)
  pluginval_is_installed(IS_PLUGINVAL_INSTALLED)
  if(NOT ${IS_PLUGINVAL_INSTALLED})
    message(
      FATAL_ERROR
        "Pluginval must be installed on the machine! You can use one of the installation instruction here -> https://github.com/Tracktion/pluginval#installation"
    )
  endif()

  set(options FATAL_ERROR)
  set(oneValueArgs)
  set(multiValueArgs VERSION)
  cmake_parse_arguments(PLUGINVAL_MINIMUM_REQUIRED "${options}"
                        "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  # If zero version are passed
  if(NOT DEFINED PLUGINVAL_MINIMUM_REQUIRED_VERSION)
    message(
      FATAL_ERROR
        "No VERSION passed to pluginval_minimum_required. Please add one or a range of versions"
    )
  endif()

  list(LENGTH PLUGINVAL_MINIMUM_REQUIRED_VERSION NUMBER_OF_VERSIONS_INPUT)

  # If more than three versions are passed
  if(${NUMBER_OF_VERSIONS_INPUT} GREATER_EQUAL 3)
    message(
      FATAL_ERROR
        "Too much versions(${NUMBER_OF_VERSIONS_INPUT}) given. You can only pass one or a range of versions to pluginval_minimum_required."
    )
  endif()

  # Get the pluginval actual version
  pluginval_version(PLUGINVAL_ACTUAL_VERSION)

  # Sets the warning level when amismatch in the version is found
  set(WARNING_LEVEL WARNING)
  if(PLUGINVAL_MINIMUM_REQUIRED_FATAL_ERROR)
    set(WARNING_LEVEL FATAL_ERROR)
  endif()

  # If one version is passed
  if(${NUMBER_OF_VERSIONS_INPUT} EQUAL 1)
    # Gets the expected minimum version from the user
    list(GET PLUGINVAL_MINIMUM_REQUIRED_VERSION 0 MINIMUM_VERSION_EXPECTED)

    # Displays a message if the version installed is older that the one expected
    if(MINIMUM_VERSION_EXPECTED VERSION_GREATER PLUGINVAL_ACTUAL_VERSION)
      message(
        ${WARNING_LEVEL}
        "The expected version (${MINIMUM_VERSION_EXPECTED}) of pluginval is younger than the one installed (${PLUGINVAL_ACTUAL_VERSION})"
      )
    endif()
  endif()

  # If two versions are passed
  if(${NUMBER_OF_VERSIONS_INPUT} EQUAL 2)
    # Gets the expected versions range from the user
    list(GET PLUGINVAL_MINIMUM_REQUIRED_VERSION 0 MINIMUM_VERSION_EXPECTED)
    list(GET PLUGINVAL_MINIMUM_REQUIRED_VERSION 1 MAXIMAL_VERSION_EXPECTED)

    if(MINIMUM_VERSION_EXPECTED VERSION_GREATER MAXIMAL_VERSION_EXPECTED)
      message(
        FATAL_ERROR
          "The range of versions is reversed (the first one is greater than the second one - \"VERSION ${MINIMUM_VERSION_EXPECTED} ${MAXIMAL_VERSION_EXPECTED}\")."
      )
    endif()

    if(MINIMUM_VERSION_EXPECTED VERSION_EQUAL MAXIMAL_VERSION_EXPECTED)
      message(
        WARNING
          "The two versions given to pluginval_minimum_required are the same. You may want to only pass one minimal version instead."
      )
    endif()

    if(MINIMUM_VERSION_EXPECTED VERSION_GREATER PLUGINVAL_ACTUAL_VERSION)
      message(
        ${WARNING_LEVEL}
        "The minimum expected version (${MINIMUM_VERSION_EXPECTED}) of pluginval is younger than the one installed (${PLUGINVAL_ACTUAL_VERSION})"
      )
    endif()

    if(PLUGINVAL_ACTUAL_VERSION VERSION_GREATER MAXIMAL_VERSION_EXPECTED)
      message(
        ${WARNING_LEVEL}
        "The maximum expected version (${MINIMUM_VERSION_EXPECTED}) of pluginval is older than the one installed (${PLUGINVAL_ACTUAL_VERSION})"
      )
    endif()
  endif()
endfunction()

function(pluginval_check_plugin)
  pluginval_is_installed(IS_PLUGINVAL_INSTALLED)
  if(NOT ${IS_PLUGINVAL_INSTALLED})
    message(
      FATAL_ERROR
        "Pluginval must be installed on the machine! You can use one of the installation instruction here -> https://github.com/Tracktion/pluginval#installation"
    )
  endif()

  set(options)
  set(oneValueArgs STRICTNESS_LEVEL VST_LOCATION)
  set(multiValueArgs)
  cmake_parse_arguments(PLUGINVAL_CHECK_PLUGIN "${options}" "${oneValueArgs}"
                        "${multiValueArgs}" ${ARGN})

  if(NOT DEFINED PLUGINVAL_CHECK_PLUGIN_STRICTNESS_LEVEL)
    message(
      FATAL_ERROR
        "No STRICTNESS_LEVEL passed to pluginval_check_plugin. Please add one to specify the level of the tests performed by pluginval."
    )
  endif()

  if(NOT DEFINED PLUGINVAL_CHECK_PLUGIN_VST_LOCATION)
    message(
      FATAL_ERROR
        "No VST_LOCATION passed to pluginval_minimum_required. Please add the path of the VST that you want to be checked by pluginval"
    )
  endif()

  if(${PLUGINVAL_CHECK_PLUGIN_STRICTNESS_LEVEL} LESS_EQUAL 0
     OR ${PLUGINVAL_CHECK_PLUGIN_STRICTNESS_LEVEL} GREATER 10)
    message(
      FATAL_ERROR "The STRICTNESS_LEVEL must be a value in the range [1, 10].")
  endif()

  if(IS_DIRECTORY ${PLUGINVAL_CHECK_PLUGIN_VST_LOCATION})
    message(
      FATAL_ERROR
        "The VST_LOCATION must be a file, but a directory is passed to pluginval_check_plugin (${PLUGINVAL_CHECK_PLUGIN_VST_LOCATION})."
    )
  endif()

  if(NOT EXISTS ${PLUGINVAL_CHECK_PLUGIN_VST_LOCATION})
    message(
      FATAL_ERROR
        "The VST_LOCATION must be an existing file, but \"${PLUGINVAL_CHECK_PLUGIN_VST_LOCATION}\" is not found."
    )
  endif()

  execute_process(
    COMMAND
      ${PLUGINVAL_EXECUTABLE} --strictness-level
      ${PLUGINVAL_CHECK_PLUGIN_STRICTNESS_LEVEL} --validate
      ${PLUGINVAL_CHECK_PLUGIN_VST_LOCATION}
    RESULT_VARIABLE PLUGINVAL_CHECK_PLUGIN_RESULT
    OUTPUT_VARIABLE PLUGINVAL_CHECK_PLUGIN_STANDARD_OUTPUT)

  string(STRIP ${PLUGINVAL_CHECK_PLUGIN_STANDARD_OUTPUT}
               PLUGINVAL_CHECK_PLUGIN_STANDARD_OUTPUT)
  string(FIND ${PLUGINVAL_CHECK_PLUGIN_STANDARD_OUTPUT} "ALL TESTS PASSED"
              ALL_TESTS_PASSED_STRING_POSITION REVERSE)

  if(${PLUGINVAL_CHECK_PLUGIN_RESULT} EQUAL 1
     OR ${ALL_TESTS_PASSED_STRING_POSITION} EQUAL -1)
    message(
      FATAL_ERROR
        "Pluginval test failed :
      Vst location : ${PLUGINVAL_CHECK_PLUGIN_VST_LOCATION}
      Pluginval Output : ${PLUGINVAL_CHECK_PLUGIN_STANDARD_OUTPUT}")
  endif()

  message(STATUS "Pluginval test ended sucessfully")
endfunction()
