# At least 3.2 but newer is better
cmake_minimum_required(VERSION 3.2 FATAL_ERROR)
# Declare top-level project
#project(detector)
project(ai_from_dirt VERSION 0.1 LANGUAGES CXX)

# Compiler requirements for this project
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Include 3rd-party libraries as imported targets
cmessage("FOUND OpenCV: ${OpenCV_INCLUDE_DIRS}" )

find_package(Boost COMPONENTS system filesystem REQUIRED)
message("FOUND Boost: ${Boost_INCLUDE_DIRS}" )

# Targets we develop
enable_testing()

link_libraries(${Boost_SYSTEM_LIBRARY} ${Boost_FILESYSTEM_LIBRARY}  ${OpenCV_LIBS} ${PYTHON_LIBRARIES})
add_library (dirt_lib SHARED dirt.cpp cuda.cpp)

add_executable(dirt dirt.cpp cuda.cpp)
target_link_libraries(dirt ${Boost_SYSTEM_LIBRARY} ${Boost_FILESYSTEM_LIBRARY}  ${OpenCV_LIBS} ${PYTHON_LIBRARIES})