cmake_minimum_required(VERSION 3.22)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif()

set(CMAKE_CXX_FLAGS "-O3")
set(CMAKE_CXX_FLAGS_RELEASE "-O3")

# can be found with python3 -m site --user-site
set(PYTHON_LIBRARY_DIR "/root/.local/lib/python3.10/site-packages")
# Set python executable --> can be found via which python3
set(PYTHON_EXECUTABLE "/usr/bin/python3")

project(MandelbrotCUDAPython VERSION 0.1.0 LANGUAGES CXX CUDA)
include(CheckLanguage)
check_language(CUDA)

if(NOT DEFINED CMAKE_CUDA_STANDARD)
    set(CMAKE_CUDA_STANDARD 11)
    set(CMAKE_CUDA_STANDARD_REQUIRED ON)
endif()
include_directories("${CMAKE_SOURCE_DIR}/cpp/include/" "/usr/local/cuda/include")
include_directories("${CMAKE_SOURCE_DIR}/python-bindings")

file (GLOB SOURCE_FILES "cpp/src/*.c*")
file (GLOB HEADER_FILES "cpp/include/*.hpp")
file (GLOB PYTHON_FILES "python-bindings/*.c*" "python-bindings/*.hpp")

# Set up such that XCode organizes the files
source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR} FILES ${SOURCE_FILES} ${HEADER_FILES} ${PYTHON_FILES} )


include(pybind11.cmake)
pybind11_add_module(MandelbrotCUDA 
	${SOURCE_FILES}
	${HEADER_FILES}
	${PYTHON_FILES}
)

target_link_libraries(MandelbrotCUDA PUBLIC)

install(TARGETS MandelbrotCUDA
LIBRARY DESTINATION "${PYTHON_LIBRARY_DIR}"
  COMPONENT python-bindings
  )