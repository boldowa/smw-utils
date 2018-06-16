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
if(UNIX)
	set(CMAKE_C_FLAGS "-std=c99 -fPIC")
	set(CMAKE_CXX_FLAGS "-fPIC")
	set(CMAKE_C_FLAGS_DEBUG "-O0 -g3")
	set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG}")
	set(CMAKE_C_FLAGS_RELEASE "-O2 -DNDEBUG")
	set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE}")
	set(CMAKE_EXE_LINKER_FLAGS_RELEASE "-s -Wl,--gc-sections")
	#set(CMAKE_STATIC_LINKER_FLAGS_RELEASE "-T")
	set(CMAKE_SHARED_LINKER_FLAGS_RELEASE "-s -Wl,--gc-sections")
endif(UNIX)


#--- Set build options
# CppUTest
option(EXTENSIONS "Uses CppUTestExt" OFF)
option(TESTS "Tests CppUTest library" OFF)
# Jansson
option(JANSSON_BUILD_SHARED_LIBS "build shared lib" ON)
option(JANSSON_WITHOUT_TESTS "without jannson's tests" ON)
option(JANSSON_INSTALL "without jansson's install feature" OFF)
option(JANSSON_BUILD_DOCS "without jannnson's doc builds" OFF)
# Asar
option(ASAR_GEN_EXE "generate asar standalone executable" OFF)
option(ASAR_GEN_EXE_TEST "executes asar test code for exe" OFF)
option(ASAR_GEN_DLL_TEST "executes asar test code for dll" OFF)
option(ASAR_COVERAGE "Asar coverage" OFF)
# bolib2
option(BOLIB2_EXECUTE_TEST "tests bolib2" OFF)


# Libraries / Components
if(SMW_UTIL_EXECUTE_TEST)
  add_subdirectory(cpputest)
endif(SMW_UTIL_EXECUTE_TEST)
set(CPPUTEST_ALREADY_INCLUDED ON)
add_subdirectory(jansson)
add_subdirectory(asar/src)
#add_subdirectory(Trasm)
add_subdirectory(bolib2)

# Executable
#add_subdirectory(unko)
add_subdirectory(GIEPY)

# Verbose compile flags

set(CMAKE_BUILD_FLAGS "${CMAKE_C_FLAGS}")
set(CMAKE_BUILD_FLAGS_XX "${CMAKE_CXX_FLAGS}")
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
	add_flags(CMAKE_BUILD_FLAGS ${CMAKE_C_FLAGS_DEBUG})
	add_flags(CMAKE_BUILD_FLAGS_XX ${CMAKE_CXX_FLAGS_DEBUG})
elseif(CMAKE_BUILD_TYPE STREQUAL "Release")
	add_flags(CMAKE_BUILD_FLAGS ${CMAKE_C_FLAGS_RELEASE})
	add_flags(CMAKE_BUILD_FLAGS_XX ${CMAKE_CXX_FLAGS_RELEASE})
endif()
message(STATUS "CMake C   compile flags(${CMAKE_BUILD_TYPE}): ${CMAKE_C_COMPILER} ${CMAKE_BUILD_FLAGS}")
message(STATUS "CMake CXX compile flags(${CMAKE_BUILD_TYPE}): ${CMAKE_CXX_COMPILER} ${CMAKE_BUILD_FLAGS_XX}")

