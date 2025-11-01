# CMakeLists.txt for Swiss Ephemeris integration

cmake_minimum_required(VERSION 3.18.1)

# Project name
project(swisseph)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find Android NDK
find_package(android REQUIRED)

# Swiss Ephemeris source files
set(SWISS_EPHEMERIS_SOURCES
    sweph/sweph.c
    sweph/swephlib.c
    sweph/swecl.c
    sweph/swedate.c
    sweph/swehouse.c
    sweph/swejpl.c
    sweph/swemmoon.c
    sweph/swemplan.c
    sweph/sweph.c
    sweph/swepcalc.c
    sweph/swepdate.c
    sweph/swephlib.c
    sweph/swehel.c
    sweph/swenut.c
)

# Create shared library
add_library(
    swisseph
    SHARED
    swisseph_wrapper.cpp
    ${SWISS_EPHEMERIS_SOURCES}
)

# Include directories
target_include_directories(
    swisseph
    PRIVATE
    sweph
    ${ANDROID_NDK}/sysroot/usr/include
)

# Compiler flags
target_compile_options(
    swisseph
    PRIVATE
    -Wall
    -Wextra
    -O3
    -fPIC
    -DANDROID
    -DUSE_DLL
)

# Link libraries
target_link_libraries(
    swisseph
    android
    log
    m
)

# Set library output name
set_target_properties(
    swisseph
    PROPERTIES
    OUTPUT_NAME "swisseph"
)
