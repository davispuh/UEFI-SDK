
cmake_minimum_required(VERSION 4.2.3)

project(UefiSdk)

set(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE)
set(ARCH X64 CACHE STRING "Target architecture (eg. X64, IA32)")
set(COMPILER CLANGPDB)
set(BUILD_TYPE RELEASE)

string(TOUPPER ${CMAKE_BUILD_TYPE} CMAKE_BUILD_TYPE)
if ("${CMAKE_BUILD_TYPE}" STREQUAL "DEBUG")
    set(BUILD_TYPE DEBUG)
endif()

include(GNUInstallDirs)
set(INCLUDE_INSTALL_DIR ${CMAKE_INSTALL_INCLUDEDIR}/uefi CACHE PATH "Location of header files")

include(FetchContent)

add_link_options(-flto)

FetchContent_Declare(edk2
                     GIT_REPOSITORY https://github.com/tianocore/edk2.git)

FetchContent_Declare(edk2-libc
                     GIT_REPOSITORY https://github.com/tianocore/edk2-libc.git)

FetchContent_MakeAvailable(edk2 edk2-libc)

set(PKG SdkPkg)
add_custom_command(
  OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/Build/${PKG}/${BUILD_TYPE}_${COMPILER}/${ARCH}/StdLib/LibC/LibC/OUTPUT/Main/Main.obj"
         "${CMAKE_CURRENT_BINARY_DIR}/Build/${PKG}/${BUILD_TYPE}_${COMPILER}/${ARCH}/${PKG}/UefiApp/OUTPUT/AutoGen.obj"
         "${CMAKE_CURRENT_BINARY_DIR}/Build/${PKG}/${BUILD_TYPE}_${COMPILER}/${ARCH}/${PKG}/UefiApp/OUTPUT/static_library_files.lst"
         "${CMAKE_CURRENT_BINARY_DIR}/Build/${PKG}/${BUILD_TYPE}_${COMPILER}/${ARCH}/StdLib/LibC/LibC/OUTPUT/object_files.lst"
         "${CMAKE_CURRENT_BINARY_DIR}/Build/${PKG}/${BUILD_TYPE}_${COMPILER}/${ARCH}/ShellPkg/Library/UefiShellCEntryLib/UefiShellCEntryLib/OUTPUT/UefiShellCEntryLib.obj"
  COMMAND make -C ${edk2_SOURCE_DIR}/BaseTools && mkdir -p ${CMAKE_CURRENT_BINARY_DIR}/Conf
  COMMAND "${CMAKE_COMMAND}" -E env "RECONFIG=FALSE"
                                    "WORKSPACE=${CMAKE_CURRENT_BINARY_DIR}"
                                    "EDK_TOOLS_PATH=${edk2_SOURCE_DIR}/BaseTools"
                                    "CONF_PATH=${CMAKE_CURRENT_BINARY_DIR}/Conf"
          "${edk2_SOURCE_DIR}/BaseTools/BuildEnv"
  COMMAND dos2unix "${CMAKE_CURRENT_BINARY_DIR}/Conf/tools_def.txt"
  COMMAND sed -i "/DEFINE CLANGPDB_X64_TARGET/c DEFINE CLANGPDB_X64_TARGET = -target x86_64-uefi" "${CMAKE_CURRENT_BINARY_DIR}/Conf/tools_def.txt"
  COMMAND sed -i "s/DEFINE CLANGPDB_WARNING_OVERRIDES.*/& -Wno-unused-but-set-variable/" "${CMAKE_CURRENT_BINARY_DIR}/Conf/tools_def.txt"
  COMMAND "${CMAKE_COMMAND}" -E env "PATH=${edk2_SOURCE_DIR}/BaseTools/BinWrappers/PosixLike:$ENV{PATH}"
                                    "EDK_TOOLS_PATH=${edk2_SOURCE_DIR}/BaseTools"
                                    "CONF_PATH=${CMAKE_CURRENT_BINARY_DIR}/Conf"
                                    "WORKSPACE=${CMAKE_CURRENT_BINARY_DIR}"
                                    "PACKAGES_PATH=${edk2_SOURCE_DIR}:${edk2-libc_SOURCE_DIR}:${CMAKE_CURRENT_SOURCE_DIR}"
          build --arch=${ARCH} --buildtarget=${BUILD_TYPE} --tagname=${COMPILER} --platform=${PKG}/${PKG}.dsc
  DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/SdkPkg/SdkPkg.dsc"
          "${CMAKE_CURRENT_SOURCE_DIR}/SdkPkg/SdkPkg.dec"
          "${CMAKE_CURRENT_SOURCE_DIR}/SdkPkg/UefiApp.inf"
          "${CMAKE_CURRENT_SOURCE_DIR}/SdkPkg/UefiApp.c"
  VERBATIM)


add_library(MdePkg INTERFACE)
add_dependencies(MdePkg edk2)
target_include_directories(MdePkg INTERFACE
                                  "${edk2_SOURCE_DIR}/MdePkg/Include"
                                  "${edk2_SOURCE_DIR}/MdePkg/Include/${ARCH}")

add_library(ShellPkg INTERFACE)
add_dependencies(ShellPkg edk2)
target_include_directories(ShellPkg INTERFACE
                                  "${edk2_SOURCE_DIR}/ShellPkg/Include")

add_library(StdLib INTERFACE)
add_dependencies(StdLib edk2)
target_include_directories(StdLib INTERFACE
                                  "${edk2-libc_SOURCE_DIR}/StdLib/Include"
                                  "${edk2-libc_SOURCE_DIR}/StdLib/Include/${ARCH}")

add_library(StdLibPrivateInternalFiles INTERFACE)
add_dependencies(StdLibPrivateInternalFiles edk2)
target_include_directories(StdLibPrivateInternalFiles INTERFACE
                           "${edk2-libc_SOURCE_DIR}/StdLibPrivateInternalFiles/Include")

add_library(UefiSdk STATIC)
set_target_properties(UefiSdk
        PROPERTIES
        LINKER_LANGUAGE C
        PREFIX ""
        SUFFIX ".lib"
)


file(GLOB HEADER_DIRS LIST_DIRECTORIES true "${edk2_SOURCE_DIR}/**/Include")
file(GLOB HEADER_DIRS2 LIST_DIRECTORIES true "${edk2-libc_SOURCE_DIR}/**/Include")
file(GLOB HEADER_ARCH_DIRS LIST_DIRECTORIES true "${edk2_SOURCE_DIR}/**/Include/${ARCH}")
file(GLOB HEADER_ARCH_DIRS2 LIST_DIRECTORIES true "${edk2-libc_SOURCE_DIR}/**/Include/${ARCH}")
file(GLOB_RECURSE HEADERS LIST_DIRECTORIES false "${edk2_SOURCE_DIR}/**/Include/**/*.h")

target_sources(UefiSdk PRIVATE FILE_SET HEADERS BASE_DIRS ${HEADER_DIRS} FILES ${HEADERS})

target_include_directories(UefiSdk INTERFACE
                                   "$<BUILD_INTERFACE:${HEADER_DIRS};${HEADER_ARCH_DIRS};${HEADER_DIRS2};${HEADER_ARCH_DIRS2}>"
                                   "$<INSTALL_INTERFACE:${INCLUDE_INSTALL_DIR}>"
                                   "$<INSTALL_INTERFACE:${INCLUDE_INSTALL_DIR}/${ARCH}>")

add_custom_target(UefiSdkLibSource
                  DEPENDS
                  "${CMAKE_CURRENT_SOURCE_DIR}/cmake/createLib.sh"
                  "${CMAKE_CURRENT_BINARY_DIR}/Build/${PKG}/${BUILD_TYPE}_${COMPILER}/${ARCH}/${PKG}/UefiApp/OUTPUT/AutoGen.obj"
                  "${CMAKE_CURRENT_BINARY_DIR}/Build/${PKG}/${BUILD_TYPE}_${COMPILER}/${ARCH}/${PKG}/UefiApp/OUTPUT/static_library_files.lst"
                  "${CMAKE_CURRENT_BINARY_DIR}/Build/${PKG}/${BUILD_TYPE}_${COMPILER}/${ARCH}/StdLib/LibC/LibC/OUTPUT/object_files.lst")
add_dependencies(UefiSdk UefiSdkLibSource)

add_custom_command(TARGET UefiSdk POST_BUILD
  COMMAND "${CMAKE_CURRENT_SOURCE_DIR}/cmake/createLib.sh"
          "${CMAKE_CURRENT_BINARY_DIR}/Build/${PKG}/${BUILD_TYPE}_${COMPILER}/${ARCH}/${PKG}/UefiApp/OUTPUT"
          "${CMAKE_CURRENT_BINARY_DIR}/Build/${PKG}/${BUILD_TYPE}_${COMPILER}/${ARCH}/StdLib/LibC/LibC/OUTPUT/object_files.lst"
          "${CMAKE_CURRENT_BINARY_DIR}"
  VERBATIM)

add_custom_command(
  OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/include"
  COMMAND mkdir -p "${CMAKE_CURRENT_BINARY_DIR}/lib"
  COMMAND find "${CMAKE_CURRENT_BINARY_DIR}/Build/${PKG}/${BUILD_TYPE}_${COMPILER}/${ARCH}" -iname "*.lib" -exec cp "{}" "${CMAKE_CURRENT_BINARY_DIR}/lib" \;
  COMMAND rm -f "${CMAKE_CURRENT_BINARY_DIR}/lib/UefiApp.lib"
  DEPENDS UefiSdk
  VERBATIM)

add_custom_target(UefiSdkHeadersTarget ALL DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/include")

add_library(UefiApp STATIC SdkPkg/UefiApp.c)
set_target_properties(UefiApp PROPERTIES
                              LINKER_LANGUAGE C
                              PREFIX ""
                              SUFFIX ".lib")
target_link_libraries(UefiApp PRIVATE
                              "$<BUILD_LOCAL_INTERFACE:MdePkg>"
                              "$<BUILD_LOCAL_INTERFACE:ShellPkg>"
                              "$<BUILD_LOCAL_INTERFACE:StdLib>"
                              "$<BUILD_LOCAL_INTERFACE:StdLibPrivateInternalFiles>")

add_library(UefiShellApp STATIC SdkPkg/UefiShellApp.c $<TARGET_OBJECTS:UefiApp>
            "${CMAKE_CURRENT_BINARY_DIR}/Build/${PKG}/${BUILD_TYPE}_${COMPILER}/${ARCH}/ShellPkg/Library/UefiShellCEntryLib/UefiShellCEntryLib/OUTPUT/UefiShellCEntryLib.obj")
set_target_properties(UefiShellApp PROPERTIES
                                   LINKER_LANGUAGE C
                                   PREFIX ""
                                   SUFFIX ".lib")
target_link_libraries(UefiShellApp PRIVATE "$<BUILD_LOCAL_INTERFACE:MdePkg>")


add_library(UefiPosixApp STATIC $<TARGET_OBJECTS:UefiShellApp>
            "${CMAKE_CURRENT_BINARY_DIR}/Build/${PKG}/${BUILD_TYPE}_${COMPILER}/${ARCH}/ShellPkg/Library/UefiShellCEntryLib/UefiShellCEntryLib/OUTPUT/UefiShellCEntryLib.obj"
            "${CMAKE_CURRENT_BINARY_DIR}/Build/${PKG}/${BUILD_TYPE}_${COMPILER}/${ARCH}/StdLib/LibC/LibC/OUTPUT/Main/Main.obj")
set_target_properties(UefiPosixApp PROPERTIES
                                   LINKER_LANGUAGE C
                                   PREFIX ""
                                   SUFFIX ".lib")


install(DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/lib/"
        DESTINATION "${CMAKE_INSTALL_LIBDIR}/uefi/${CMAKE_C_COMPILER_ARCHITECTURE_ID}"
)

install(TARGETS UefiSdk UefiApp UefiShellApp UefiPosixApp
        EXPORT UefiSdkTarget
        LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}/uefi/${CMAKE_C_COMPILER_ARCHITECTURE_ID}"
        ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}/uefi/${CMAKE_C_COMPILER_ARCHITECTURE_ID}"
        INCLUDES DESTINATION "${INCLUDE_INSTALL_DIR}")

install(FILES "${CMAKE_CURRENT_BINARY_DIR}/UefiSdk.lib"
        DESTINATION "${CMAKE_INSTALL_LIBDIR}/uefi/${CMAKE_C_COMPILER_ARCHITECTURE_ID}"
)

list(FILTER HEADER_DIRS EXCLUDE REGEX "(Private|Internal|Test)")
list(FILTER HEADER_DIRS2 EXCLUDE REGEX "(Private|Internal|Test)")
list(TRANSFORM HEADER_DIRS APPEND /)
list(TRANSFORM HEADER_DIRS2 APPEND /)
install(DIRECTORY ${HEADER_DIRS} ${HEADER_DIRS2}
        DESTINATION "${INCLUDE_INSTALL_DIR}"
)


install(EXPORT UefiSdkTarget
        DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/UefiSdk"
        FILE UefiSdkTargets.cmake
)


include(CMakePackageConfigHelpers)

configure_package_config_file(cmake/UefiSdkConfig.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/UefiSdkConfig.cmake
  INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/UefiSdkConfig
  PATH_VARS INCLUDE_INSTALL_DIR)

write_basic_package_version_file(
  ${CMAKE_CURRENT_BINARY_DIR}/UefiSdkConfigVersion.cmake
  VERSION 2.0.0
  COMPATIBILITY SameMajorVersion)

install(FILES
        "${CMAKE_CURRENT_BINARY_DIR}/UefiSdkConfig.cmake"
        "${CMAKE_CURRENT_BINARY_DIR}/UefiSdkConfigVersion.cmake"
        DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/UefiSdk")

export(EXPORT UefiSdkTarget
       FILE "${CMAKE_CURRENT_BINARY_DIR}/UefiSdkTargets.cmake")
