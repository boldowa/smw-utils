#-----------------------------------------------------------
# CMakeList
#-----------------------------------------------------------

cmake_minimum_required(VERSION 3.1)

if(NOT CMAKE_BUILD_TYPE)
        message(STATUS "No build type selected, default to Release")
        set(CMAKE_BUILD_TYPE "Release" CACHE STRING 
                "Choose the type of build, options are: Debug Release RelWithDebInfo MinSizeRel." FORCE)
endif()

if(MSVC)
	option(UNICODE "Use UNICODE" OFF)
endif()

#--- link directory
link_directories(
        "${CMAKE_CURRENT_BINARY_DIR}"
        "${CMAKE_CURRENT_BINARY_DIR}/components"
        "."
        ".."
)

add_subdirectory(asar/src)
#add_subdirectory(unko)
#add_subdirectory(giepy)



