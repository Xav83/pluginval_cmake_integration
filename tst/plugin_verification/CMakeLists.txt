cmake_minimum_required(VERSION 3.18)

project(PluginVerificationTest)

if(NOT DEFINED TEST_LEVEL)
  message(
    FATAL_ERROR
      "To be able to run a plugin test, you need to specify the variable TEST_LEVEL"
  )
endif()

if(NOT DEFINED VST_LOCATION)
  message(
    FATAL_ERROR
      "To be able to run a plugin test, you need to specify the variables VST_LOCATION"
  )
endif()

include(${CMAKE_CURRENT_LIST_DIR}/../../module/pluginval.cmake)

pluginval_check_plugin(STRICTNESS_LEVEL ${TEST_LEVEL} VST_LOCATION
                       ${VST_LOCATION})
