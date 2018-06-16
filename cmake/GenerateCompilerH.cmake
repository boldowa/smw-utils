#-------------------------------------------------
# GenerateCompilerH
#-------------------------------------------------

message(STATUS "GenerateCompilerH: CurrentDir: ${CMAKE_CURRENT_LIST_DIR}")
set(GenerateCompilerH_DIR ${CMAKE_CURRENT_LIST_DIR})

if(NOT "Windows" STREQUAL "${CMAKE_HOST_SYSTEM_NAME}")
	find_program(SH sh)
	if(NOT SH)
		message(FATAL_ERROR "program \"sh\" not found...")
	endif(NOT SH)
endif(NOT "Windows" STREQUAL "${CMAKE_HOST_SYSTEM_NAME}")


macro(GenerateCompilerH prefix OutPath)

	# cc executable
	get_filename_component(GenerateCompilerH_C_COMPILER ${CMAKE_C_COMPILER} NAME_WE)
	get_filename_component(GenerateCompilerH_CXX_COMPILER ${CMAKE_CXX_COMPILER} NAME_WE)

	# cc version
	#set(GenerateCompilerH_C_COMPILER_VERSION ${CMAKE_C_COMPILER_VERSION})
	#set(GenerateCompilerH_CXX_COMPILER_VERSION ${CMAKE_CXX_COMPILER_VERSION})

	# define prefix
	set(GenerateCompilerH_Prefix ${prefix})

	# filename
	get_filename_component(GenerateCompilerH_FName ${OutPath} NAME)

	# indef string
	string(TOUPPER ${GenerateCompilerH_FName} GenerateCompilerH_FNU)
	string(REGEX REPLACE "[\. ]" "_" GenerateCompilerH_FNUpper "${GenerateCompilerH_FNU}")

	# Generate header
	configure_file("${GenerateCompilerH_DIR}/include/compiler.h.cmakein" "${OutPath}" @ONLY)

endmacro(GenerateCompilerH prefix OutPath)
