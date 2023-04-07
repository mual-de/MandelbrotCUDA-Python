
cmake_minimum_required(VERSION 3.22)

project(MandelbrotCUDA VERSION 0.1.0 LANGUAGES CXX CUDA)
include(CheckLanguage)
check_language(CUDA)

if(NOT DEFINED CMAKE_CUDA_STANDARD)
    set(CMAKE_CUDA_STANDARD 11)
    set(CMAKE_CUDA_STANDARD_REQUIRED ON)
endif()


# Include dir
include_directories(/usr/local/include /usr/local/cuda/include)

# Src
AUX_SOURCE_DIRECTORY(src SRC_FILES)

# Headers
set(PROJECT_SOURCE_DIR "src")
set(PROJECT_INCLUDE_DIR "include")

set(MandelbrotCudaHeaders
    "${PROJECT_INCLUDE_DIR}/IMandelbrot.hpp"
    "${PROJECT_INCLUDE_DIR}/MandelbrotCPU.hpp"
    "${PROJECT_INCLUDE_DIR}/MandelbrotCUDA.hpp"
)
# Source files
set(SOURCE_FILES
    ${MandelbrotCudaHeaders}
    ${PROJECT_SOURCE_DIR}/MandelbrotCPU.cpp
    ${PROJECT_SOURCE_DIR}/MandelbrotCUDA.cu
)

# Set up such that XCode organizes the files correctly
source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR} FILES ${SOURCE_FILES})

#include(FindCUDA) 

# Add library
add_library(MandelbrotCUDA SHARED ${SOURCE_FILES})
# Enable fPIC flag
set_target_properties(MandelbrotCUDA PROPERTIES POSITION_INDEPENDENT_CODE ON)

set_target_properties(MandelbrotCUDA PROPERTIES CUDA_SEPARABLE_COMPILATION ON)

set_target_properties(MandelbrotCUDA PROPERTIES CUDA_ARCHITECTURES 50 72 86)

# Include directories
target_include_directories(MandelbrotCUDA PUBLIC ${PROJECT_INCLUDE_DIR})
set_target_properties(MandelbrotCUDA PROPERTIES PUBLIC_HEADER "${MandelbrotCudaHeaders}")
install(TARGETS MandelbrotCUDA EXPORT MandelbrotCUDATargets
            RUNTIME DESTINATION bin/MandelbrotCUDA
            LIBRARY DESTINATION lib/MandelbrotCUDA
            PUBLIC_HEADER DESTINATION include/MandelbrotCUDA)