# Locate and configure the Capnproto library.
#
# The following variables can be set and are optional:
#
#   CAPNP_SRC_ROOT_FOLDER - When compiling with MSVC, if this cache variable is set
#                              the capnp-default VS project build locations
#                              (vsprojects/Debug & vsprojects/Release) will be searched
#                              for libraries and binaries.
#
#   CAPNP_IMPORT_DIRS     - List of additional directories to be searched for
#                              imported .proto files. (New in CMake 2.8.8)
#
# Defines the following variables:
#
#   CAPNP_FOUND - Found the Google Protocol Buffers library (libcapnp & header files)
#   CAPNP_INCLUDE_DIRS - Include directories for Google Protocol Buffers
#   CAPNP_LIBRARIES - The capnp libraries
# [New in CMake 2.8.5]
#   CAPNP_CAPNPC_LIBRARIES - The capnpc libraries
#   CAPNP_LITE_LIBRARIES - The capnp-lite libraries
#
# The following cache variables are also available to set or use:
#   CAPNP_LIBRARY - The capnp library
#   CAPNP_CAPNPC_LIBRARY   - The capnpc library
#   CAPNP_INCLUDE_DIR - The include directory for protocol buffers
#   CAPNP_CAPNPC_EXECUTABLE - The capnpc compiler
# [New in CMake 2.8.5]
#   CAPNP_LIBRARY_DEBUG - The capnp library (debug)
#   CAPNP_CAPNPC_LIBRARY_DEBUG   - The capnpc library (debug)
#   CAPNP_LITE_LIBRARY - The capnp lite library
#   CAPNP_LITE_LIBRARY_DEBUG - The capnp lite library (debug)
#
#  ====================================================================
#  Example:
#
#   find_package(Capnp REQUIRED)
#   include_directories(${CAPNP_INCLUDE_DIRS})
#
#   include_directories(${CMAKE_CURRENT_BINARY_DIR})
#   CAPNP_GENERATE_CPP(PROTO_SRCS PROTO_HDRS foo.proto)
#   add_executable(bar bar.cc ${PROTO_SRCS} ${PROTO_HDRS})
#   target_link_libraries(bar ${CAPNP_LIBRARIES})
#
# NOTE: You may need to link against pthreads, depending
#       on the platform.
#
# NOTE: The CAPNP_GENERATE_CPP macro & add_executable() or add_library()
#       calls only work properly within the same directory.
#
#  ====================================================================
#
# CAPNP_GENERATE_CPP (public function)
#   SRCS = Variable to define with autogenerated
#          source files
#   HDRS = Variable to define with autogenerated
#          header files
#   ARGN = proto files
#
# CAPNP_GENERATE_C (same but uses capnp-c)
#
#  ====================================================================


#=============================================================================
# Copyright 2009 Kitware, Inc.
# Copyright 2009-2011 Philip Lowman <philip@yhbt.com>
# Copyright 2008 Esben Mose Hansen, Ange Optimization ApS
#
# Distributed under the OSI-approved BSD License (the "License");
# see accompanying file Copyright.txt for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.
#=============================================================================
# (To distribute this file outside of CMake, substitute the full
#  License text for the above reference.)

function(CAPNP_GENERATE_CPP SRCS HDRS)
  if(NOT ARGN)
    message(SEND_ERROR "Error: CAPNP_GENERATE_CPP() called without any proto files")
    return()
  endif(NOT ARGN)

  if(CAPNP_GENERATE_CPP_APPEND_PATH)
    # Create an include path for each file specified
    foreach(FIL ${ARGN})
      get_filename_component(ABS_FIL ${FIL} ABSOLUTE)
      get_filename_component(ABS_PATH ${ABS_FIL} PATH)
      list(FIND _capnp_include_path ${ABS_PATH} _contains_already)
      if(${_contains_already} EQUAL -1)
          list(APPEND _capnp_include_path -I ${ABS_PATH})
      endif()
    endforeach()
  else()
    set(_capnp_include_path -I ${CMAKE_CURRENT_SOURCE_DIR})
  endif()

  if(DEFINED CAPNP_IMPORT_DIRS)
    foreach(DIR ${CAPNP_IMPORT_DIRS})
      get_filename_component(ABS_PATH ${DIR} ABSOLUTE)
      list(FIND _capnp_include_path ${ABS_PATH} _contains_already)
      if(${_contains_already} EQUAL -1)
          list(APPEND _capnp_include_path -I ${ABS_PATH})
      endif()
    endforeach()
  endif()

  set(${SRCS})
  set(${HDRS})
  foreach(FIL ${ARGN})
    get_filename_component(ABS_FIL ${FIL} ABSOLUTE)
    get_filename_component(FIL_WE ${FIL} NAME_WE)
    get_filename_component(FIL_DIR ${FIL} PATH)
    
    list(APPEND ${SRCS} "${CMAKE_CURRENT_BINARY_DIR}/${FIL_WE}.capnp.c++")
    list(APPEND ${HDRS} "${CMAKE_CURRENT_BINARY_DIR}/${FIL_WE}.capnp.h")

    add_custom_command(
      OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${FIL_WE}.capnp.c++"
             "${CMAKE_CURRENT_BINARY_DIR}/${FIL_WE}.capnp.h"
      COMMAND  ${CAPNP_CAPNPC_EXECUTABLE}
      ARGS --src-prefix=${FIL_DIR} -oc++:${CMAKE_CURRENT_BINARY_DIR} ${_capnp_include_path} "${FIL}"
      DEPENDS ${ABS_FIL}
      COMMENT "Running C++ capnp compiler on ${FIL}"
      VERBATIM )
  endforeach()

  set_source_files_properties(${${SRCS}} ${${HDRS}} PROPERTIES GENERATED TRUE)
  set(${SRCS} ${${SRCS}} PARENT_SCOPE)
  set(${HDRS} ${${HDRS}} PARENT_SCOPE)
endfunction()

function(CAPNP_GENERATE_C SRCS HDRS)
  if(NOT ARGN)
    message(SEND_ERROR "Error: CAPNP_GENERATE_C() called without any proto files")
    return()
  endif(NOT ARGN)

  if(CAPNP_GENERATE_CPP_APPEND_PATH)
    # Create an include path for each file specified
    foreach(FIL ${ARGN})
      get_filename_component(ABS_FIL ${FIL} ABSOLUTE)
      get_filename_component(ABS_PATH ${ABS_FIL} PATH)
      list(FIND _capnp_include_path ${ABS_PATH} _contains_already)
      if(${_contains_already} EQUAL -1)
          list(APPEND _capnp_include_path -I ${ABS_PATH})
      endif()
    endforeach()
  else()
    set(_capnp_include_path -I ${CMAKE_CURRENT_SOURCE_DIR})
  endif()

  if(DEFINED CAPNP_IMPORT_DIRS)
    foreach(DIR ${CAPNP_IMPORT_DIRS})
      get_filename_component(ABS_PATH ${DIR} ABSOLUTE)
      list(FIND _capnp_include_path ${ABS_PATH} _contains_already)
      if(${_contains_already} EQUAL -1)
          list(APPEND _capnp_include_path -I ${ABS_PATH})
      endif()
    endforeach()
  endif()

  set(${SRCS})
  set(${HDRS})
  foreach(FIL ${ARGN})
    get_filename_component(ABS_FIL ${FIL} ABSOLUTE)
    get_filename_component(FIL_WE ${FIL} NAME_WE)
    
    list(APPEND ${SRCS} "${CMAKE_CURRENT_BINARY_DIR}/${FIL_WE}.pb-c.c")
    list(APPEND ${HDRS} "${CMAKE_CURRENT_BINARY_DIR}/${FIL_WE}.pb-c.h")

    add_custom_command(
      OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${FIL_WE}.pb-c.c"
             "${CMAKE_CURRENT_BINARY_DIR}/${FIL_WE}.pb-c.h"
      COMMAND  ${CAPNP_CAPNPCC_EXECUTABLE}
      ARGS --c_out=${CMAKE_CURRENT_BINARY_DIR} ${_capnp_include_path} ${ABS_FIL}
      DEPENDS ${ABS_FIL}
      COMMENT "Running C++ protocol buffer compiler on ${FIL}"
      VERBATIM )
  endforeach()

  set_source_files_properties(${${SRCS}} ${${HDRS}} PROPERTIES GENERATED TRUE)
  set(${SRCS} ${${SRCS}} PARENT_SCOPE)
  set(${HDRS} ${${HDRS}} PARENT_SCOPE)
endfunction()

# Internal function: search for normal library as well as a debug one
#    if the debug one is specified also include debug/optimized keywords
#    in *_LIBRARIES variable
function(_capnp_find_libraries name filename)
   find_library(${name}_LIBRARY
       NAMES ${filename}
       PATHS ${CAPNP_SRC_ROOT_FOLDER}/vsprojects/Release)
   mark_as_advanced(${name}_LIBRARY)

   find_library(${name}_LIBRARY_DEBUG
       NAMES ${filename}
       PATHS ${CAPNP_SRC_ROOT_FOLDER}/vsprojects/Debug)
   mark_as_advanced(${name}_LIBRARY_DEBUG)

   if(NOT ${name}_LIBRARY_DEBUG)
      # There is no debug library
      set(${name}_LIBRARY_DEBUG ${${name}_LIBRARY} PARENT_SCOPE)
      set(${name}_LIBRARIES     ${${name}_LIBRARY} PARENT_SCOPE)
   else()
      # There IS a debug library
      set(${name}_LIBRARIES
          optimized ${${name}_LIBRARY}
          debug     ${${name}_LIBRARY_DEBUG}
          PARENT_SCOPE
      )
   endif()
endfunction()

#
# Main.
#

# By default have CAPNP_GENERATE_CPP macro pass -I to capnpc
# for each directory where a proto file is referenced.
if(NOT DEFINED CAPNP_GENERATE_CPP_APPEND_PATH)
  set(CAPNP_GENERATE_CPP_APPEND_PATH TRUE)
endif()


# Google's provided vcproj files generate libraries with a "lib"
# prefix on Windows
if(MSVC)
    set(CAPNP_ORIG_FIND_LIBRARY_PREFIXES "${CMAKE_FIND_LIBRARY_PREFIXES}")
    set(CMAKE_FIND_LIBRARY_PREFIXES "lib" "")

    find_path(CAPNP_SRC_ROOT_FOLDER capnp.pc.in)
endif()

# The Capnp library
_capnp_find_libraries(CAPNP capnp)
_capnp_find_libraries(CAPNPC capnp-c)
#DOC "The Google Protocol Buffers RELEASE Library"

_capnp_find_libraries(CAPNP_LITE capnp-lite)

# The Capnp Capnpc Library
_capnp_find_libraries(CAPNP_CAPNPC capnpc)

# Restore original find library prefixes
if(MSVC)
    set(CMAKE_FIND_LIBRARY_PREFIXES "${CAPNP_ORIG_FIND_LIBRARY_PREFIXES}")
endif()


# Find the include directory
find_path(CAPNP_INCLUDE_DIR
    capnp/message.h
    PATHS ${CAPNP_SRC_ROOT_FOLDER}/src
)
mark_as_advanced(CAPNP_INCLUDE_DIR)

# Find the capnpc Executable
find_program(CAPNP_CAPNPC_EXECUTABLE
    NAMES capnpc
    DOC "The Google Protocol Buffers Compiler"
    PATHS
    ${CAPNP_SRC_ROOT_FOLDER}/vsprojects/Release
    ${CAPNP_SRC_ROOT_FOLDER}/vsprojects/Debug
)
mark_as_advanced(CAPNP_CAPNPC_EXECUTABLE)

# Find the capnpc-c Executable
find_program(CAPNP_CAPNPCC_EXECUTABLE
    NAMES capnpc-c
    DOC "The Google Protocol Buffers Compiler for C"
    PATHS
    ${CAPNP_SRC_ROOT_FOLDER}/vsprojects/Release
    ${CAPNP_SRC_ROOT_FOLDER}/vsprojects/Debug
)
mark_as_advanced(CAPNP_CAPNPCC_EXECUTABLE)

include(${CMAKE_ROOT}/Modules/FindPackageHandleStandardArgs.cmake)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(CAPNP DEFAULT_MSG
    CAPNP_LIBRARY CAPNP_INCLUDE_DIR)

if(CAPNP_FOUND)
    set(CAPNP_INCLUDE_DIRS ${CAPNP_INCLUDE_DIR})
endif()