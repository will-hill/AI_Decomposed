# At least 3.2 but newer is better
cmake_minimum_required(VERSION 3.2 FATAL_ERROR)
# Declare top-level project
#project(detector)
project(ai_from_dirt VERSION 0.1 LANGUAGES CXX)

# Compiler requirements for this project
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Include 3rd-party libraries as imported targets
find_package(OpenCV 3 REQUIRED)
message("FOUND OpenCV: ${OpenCV_INCLUDE_DIRS}" )

find_package(Boost COMPONENTS system filesystem REQUIRED)
message("FOUND Boost: ${Boost_INCLUDE_DIRS}" )

set(PYTHON_INCLUDE_DIRS "/anaconda3/include/python3.7m/")
set(PYTHON_LIBRARIES "/anaconda3/lib/libpython3.7m.dylib")
#find_package(PythonLibs 3 REQUIRED HINTS "/anaconda3/include/python3.7m" "/anaconda3/include/python3.7" "/anaconda3/include")
message("FOUND Python: ${PythonLibs_INCLUDE_DIRS}" )

# Targets we develop
enable_testing()

link_libraries(${Boost_SYSTEM_LIBRARY} ${Boost_FILESYSTEM_LIBRARY}  ${OpenCV_LIBS} ${PYTHON_LIBRARIES})
add_library (dirt_lib SHARED dirt.cpp)

add_executable(dirt dirt.cpp)
target_link_libraries(dirt ${Boost_SYSTEM_LIBRARY} ${Boost_FILESYSTEM_LIBRARY}  ${OpenCV_LIBS} ${PYTHON_LIBRARIES})