# At least 3.2 but newer is better
cmake_minimum_required(VERSION 3.2 FATAL_ERROR)
# project(    cmake_and_cuda              LANGUAGES CXX CUDA)
project(    gpu_pooling     VERSION 0.1 LANGUAGES CXX CUDA)


include(CTest)

# add_library ( particles STATIC )

# Compiler requirements for this project
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

enable_testing()

add_library (gpu_pooling SHARED gpu_hello.cpp)

add_executable(gpu_pooling_e gpu_hello.cpp)
target_link_libraries(gpu_pooling)

