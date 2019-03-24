# At least 3.2 but newer is better
cmake_minimum_required(VERSION 3.2 FATAL_ERROR)
# Declare top-level project
#project(detector)
project(ai_from_dirt VERSION 0.1 LANGUAGES CXX)

# Compiler requirements for this project
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

enable_testing()

add_library (convolution SHARED convolution.cpp)

add_executable(convolution_e convolution.cpp)
target_link_libraries(convolution)
