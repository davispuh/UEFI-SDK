
cmake_minimum_required(VERSION 4.2.3)

project(UefiExamples)

find_package(UefiSdk 2.0.0 REQUIRED)

add_link_options(-flto)

add_executable(bareApp bareApp.c)
target_link_libraries(bareApp UefiSdk)
target_include_directories(bareApp PUBLIC ${UefiSdk_INCLUDE_DIRS})
set_target_properties(UefiPosixApp PROPERTIES
                                   LINKER_LANGUAGE C
                                   PREFIX ""
                                   SUFFIX ".lib")

add_executable(uefiApp uefiApp.c)
target_link_libraries(uefiApp UefiSdk UefiApp)

add_executable(shellApp shellApp.c)
target_link_libraries(shellApp UefiSdk UefiShellApp)

add_executable(posixApp posixApp.c)
target_link_libraries(posixApp UefiSdk UefiPosixApp)
