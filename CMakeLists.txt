# Specify the minimum required version of CMake
cmake_minimum_required(VERSION 3.16)

# Include the FetchContent module
include(FetchContent)

# Define the project name and programming language
project(nvidia-pstated C)

# Find the CUDAToolkit package
find_package(CUDAToolkit REQUIRED COMPONENTS nvml)

# Define the executable target
add_executable(nvidia-pstated
  src/main.c
  src/nvapi.c
  src/utils.c
)

# Include directories for the target
target_include_directories(nvidia-pstated SYSTEM PRIVATE
  R555-OpenSource
)

# Link libraries
target_link_libraries(nvidia-pstated PRIVATE
  CUDA::nvml
)

# Conditional linking for Linux platform
if(UNIX AND NOT APPLE)
  target_link_libraries(nvidia-pstated PRIVATE
    dl
  )
endif()

install(TARGETS nvidia-pstated
  RUNTIME DESTINATION bin
)
