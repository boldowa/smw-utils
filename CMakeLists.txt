#-----------------------------------------------------------
# CMakeList
#-----------------------------------------------------------

cmake_minimum_required(VERSION 3.1)
set(DefaultBuildType "Release")
#project(SMW-Utils C CXX)

if(NOT CMAKE_BUILD_TYPE)
	message(STATUS "No build type selected, default to ${DefaultBuildType}")
	set(CMAKE_BUILD_TYPE "${DefaultBuildType}" CACHE STRING 
                "Choose the type of build, options are: Debug Release RelWithDebInfo MinSizeRel." FORCE)
endif()

set(PCBDIR "${CMAKE_SOURCE_DIR}/pcb")
set(TRASM_NAME "trasm_b")
set(ASAR_NAME "asar")
if("Linux" STREQUAL "${CMAKE_SYSTEM_NAME}")
	set(SLIB_PREFIX "lib")
	set(SLIB_SUFFIX ".so")
	set(EXE_SUFFIX "")
elseif(APPLE)
	set(SLIB_PREFIX "lib")
	set(SLIB_SUFFIX ".dy")
	set(EXE_SUFFIX "")
elseif("Windows" STREQUAL "${CMAKE_SYSTEM_NAME}")
	set(SLIB_PREFIX "")
	set(SLIB_SUFFIX ".dll")
	set(EXE_SUFFIX ".exe")
else("Linux" STREQUAL "${CMAKE_SYSTEM_NAME}")
	set(SLIB_PREFIX "")
	set(SLIB_SUFFIX "")
	set(EXE_SUFFIX "")
endif("Linux" STREQUAL "${CMAKE_SYSTEM_NAME}")

option(SMW_UTIL_EXECUTE_TEST "Execute test suite" ON)
if(NOT CMAKE_BUILD_TYPE STREQUAL "Debug")
	set(SMW_UTIL_EXECUTE_TEST OFF)
endif(NOT CMAKE_BUILD_TYPE STREQUAL "Debug")

include(cmake/macs.cmake)
include(cmake/GenerateCompilerH.cmake)

if(MSVC)
	option(UNICODE "Use UNICODE" OFF)
endif(MSVC)

if(UNICODE)
	add_flags(CMAKE_C_FLAGS "-DUNICODE -D_UNICODE")
endif(UNICODE)

#--- link directory
link_directories(".")

# GLOBAL Compile flags
if(UNIX OR MINGW)
	set(CMAKE_C_FLAGS "-std=gnu99 -fPIC")
	set(CMAKE_CXX_FLAGS "-fPIC")
	set(CMAKE_C_FLAGS_DEBUG "-O0 -g3")
	set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG}")
	set(CMAKE_C_FLAGS_RELEASE "-O2 -DNDEBUG")
	set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE}")
	set(CMAKE_EXE_LINKER_FLAGS_RELEASE "-s -Wl,--gc-sections")
	#set(CMAKE_STATIC_LINKER_FLAGS_RELEASE "-T")
	set(CMAKE_SHARED_LINKER_FLAGS_RELEASE "-s -Wl,--gc-sections")
endif(UNIX OR MINGW)


#--- Set build options
# CppUTest
option(EXTENSIONS "Uses CppUTestExt" OFF)
option(TESTS "Tests CppUTest library" OFF)
# Jansson
option(JANSSON_BUILD_SHARED_LIBS "build shared lib" ON)
option(JANSSON_WITHOUT_TESTS "without jannson's tests" ON)
option(JANSSON_INSTALL "without jansson's install feature" OFF)
option(JANSSON_BUILD_DOCS "without jannnson's doc builds" OFF)
option(JANSSON_EXAMPLES "without jansson's example" OFF)
# Asar
option(ASAR_GEN_EXE "generate asar standalone executable" OFF)
option(ASAR_GEN_EXE_TEST "executes asar test code for exe" OFF)
option(ASAR_GEN_DLL_TEST "executes asar test code for dll" OFF)
option(ASAR_COVERAGE "Asar coverage" OFF)
# bolib2
option(BOLIB2_EXECUTE_TEST "tests bolib2" OFF)
if("Release" STREQUAL "${CMAKE_BUILD_TYPE}")
	option(BOLIB2_TESTBUILD "Release build" OFF)
endif("Release" STREQUAL "${CMAKE_BUILD_TYPE}")


# Env
set(ASAR_SLIB "${SLIB_PREFIX}${ASAR_NAME}${SLIB_SUFFIX}")
set(TRASM_EXE "${TRASM_NAME}${EXE_SUFFIX}")


# Libraries / Components
if(SMW_UTIL_EXECUTE_TEST)
  add_subdirectory(cpputest)
endif(SMW_UTIL_EXECUTE_TEST)
set(CPPUTEST_ALREADY_INCLUDED ON)

add_subdirectory(jansson)
if(MINGW OR WIN32)
	set_target_properties(jansson PROPERTIES PREFIX "")
endif(MINGW OR WIN32)

if(EXISTS "${PCBDIR}/${ASAR_SLIB}")
	set(ASAR_PATH "${PCBDIR}/${ASAR_SLIB}")
else(EXISTS "${PCBDIR}/${ASAR_NAME}/${ASAR_SLIB}")
	add_subdirectory(asar/src)
	if(MINGW OR WIN32)
		set_target_properties(asar PROPERTIES PREFIX "")
	endif(MINGW OR WIN32)
	set(ASAR_PATH $<TARGET_FILE:asar>)
endif(EXISTS "${PCBDIR}/${ASAR_SLIB}")

if(EXISTS "${PCBDIR}/${TRASM_EXE}")
	set(TRASM_PATH "${PCBDIR}/${TRASM_EXE}")
else(EXISTS "${PCBDIR}/${TRASM_EXE}")
	add_subdirectory(Trasm)
	set(TRASM_PATH ${CMAKE_BINARY_DIR}/Trasm/${TRASM_EXE})
endif(EXISTS "${PCBDIR}/${TRASM_EXE}")

add_subdirectory(bolib2)



# Executable
add_subdirectory(unko)
add_subdirectory(GIEPY)


# Copy GIEPY components
set(GIEPY_COMPONENTS_PATH "${CMAKE_BINARY_DIR}/GIEPY/components")
set_target_properties(jansson PROPERTIES
	LIBRARY_OUTPUT_DIRECTORY "${GIEPY_COMPONENTS_PATH}"
	RUNTIME_OUTPUT_DIRECTORY "${GIEPY_COMPONENTS_PATH}"
	)
add_custom_target(g_copy_components
	SOURCES
	"${GIEPY_COMPONENTS_PATH}/${TRASM_EXE}"
	"${GIEPY_COMPONENTS_PATH}/${ASAR_SLIB}")
add_custom_command(OUTPUT "${GIEPY_COMPONENTS_PATH}/${TRASM_EXE}"
	COMMAND ${CMAKE_COMMAND} -E copy_if_different "${TRASM_PATH}" "${GIEPY_COMPONENTS_PATH}/")
add_custom_command(OUTPUT "${GIEPY_COMPONENTS_PATH}/${ASAR_SLIB}"
	COMMAND ${CMAKE_COMMAND} -E copy_if_different "${ASAR_PATH}" "${GIEPY_COMPONENTS_PATH}/")
add_dependencies(mewthree g_copy_components)


# Copy UNKO components
set(UNKO_COMPONENTS_PATH "${CMAKE_BINARY_DIR}/unko")
add_custom_target(u_copy_components
	SOURCES
	"${UNKO_COMPONENTS_PATH}/${ASAR_SLIB}")
add_custom_command(OUTPUT "${UNKO_COMPONENTS_PATH}/${ASAR_SLIB}"
	COMMAND ${CMAKE_COMMAND} -E copy_if_different "${ASAR_PATH}" "${UNKO_COMPONENTS_PATH}/")
add_dependencies(unko u_copy_components)



# Verbose compile flags
set(CMAKE_BUILD_FLAGS "${CMAKE_C_FLAGS}")
set(CMAKE_BUILD_FLAGS_XX "${CMAKE_CXX_FLAGS}")
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
	add_flags(CMAKE_BUILD_FLAGS ${CMAKE_C_FLAGS_DEBUG})
	add_flags(CMAKE_BUILD_FLAGS_XX ${CMAKE_CXX_FLAGS_DEBUG})
elseif(CMAKE_BUILD_TYPE STREQUAL "Release")
	add_flags(CMAKE_BUILD_FLAGS ${CMAKE_C_FLAGS_RELEASE})
	add_flags(CMAKE_BUILD_FLAGS_XX ${CMAKE_CXX_FLAGS_RELEASE})
endif(CMAKE_BUILD_TYPE STREQUAL "Debug")
message(STATUS "CMake C   compile flags(${CMAKE_BUILD_TYPE}): ${CMAKE_C_COMPILER} ${CMAKE_BUILD_FLAGS}")
message(STATUS "CMake CXX compile flags(${CMAKE_BUILD_TYPE}): ${CMAKE_CXX_COMPILER} ${CMAKE_BUILD_FLAGS_XX}")

