################################################################################
# Project:  Lib XML2
# Purpose:  CMake build scripts
# Author:   Dmitry Baryshnikov, dmitry.baryshnikov@nexgis.com
################################################################################
# Copyright (C) 2015-2018, NextGIS <info@nextgis.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.
################################################################################

cmake_minimum_required(VERSION 2.8.12 FATAL_ERROR)

project(xml2)

if(NOT DEFINED PACKAGE_VENDOR)
    set(PACKAGE_VENDOR NextGIS)
endif()

if(NOT DEFINED PACKAGE_BUGREPORT)
    set(PACKAGE_BUGREPORT info@nextgis.com)
endif()

# some init settings
set(CMAKE_COLOR_MAKEFILE ON)
# set path to additional CMake modules
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake ${CMAKE_MODULE_PATH})

if(OSX_FRAMEWORK AND (BUILD_SHARED_LIBS OR BUILD_STATIC_LIBS))
  message(FATAL_ERROR "Only OSX_FRAMEWORK key or any or both BUILD_SHARED_LIBS
                       and BUILD_STATIC_LIBS keys are permitted")
endif()

if(OSX_FRAMEWORK)
    set(INSTALL_BIN_DIR "bin" CACHE INTERNAL "Installation directory for executables" FORCE)
    set(INSTALL_LIB_DIR "Library/Frameworks" CACHE INTERNAL "Installation directory for libraries" FORCE)
    set(INSTALL_INC_DIR "${INSTALL_LIB_DIR}/${PROJECT_NAME}.framework/Headers" CACHE INTERNAL "Installation directory for headers" FORCE)
    set(INSTALL_CMAKECONF_DIR ${INSTALL_LIB_DIR}/${PROJECT_NAME}.framework/Resources/CMake CACHE INTERNAL "Installation directory for cmake config files" FORCE)
    set(SKIP_INSTALL_HEADERS ON)
    set(SKIP_INSTALL_EXECUTABLES ON)
    set(SKIP_INSTALL_FILES ON)
    set(SKIP_INSTALL_EXPORT ON)
    set(CMAKE_MACOSX_RPATH ON)
else()
    include(GNUInstallDirs)

    set(INSTALL_BIN_DIR ${CMAKE_INSTALL_BINDIR} CACHE INTERNAL "Installation directory for executables" FORCE)
    set(INSTALL_LIB_DIR ${CMAKE_INSTALL_LIBDIR} CACHE INTERNAL "Installation directory for libraries" FORCE)
    set(INSTALL_INC_DIR ${CMAKE_INSTALL_INCLUDEDIR} CACHE INTERNAL "Installation directory for headers" FORCE)
    set(INSTALL_SHARE_DIR ${CMAKE_INSTALL_DATADIR} CACHE INTERNAL "Shared files directory" FORCE)
    set(INSTALL_DATA_DIR "${INSTALL_SHARE_DIR}/proj" CACHE INTERNAL "Shared files directory" FORCE)
    set(INSTALL_MAN_DIR ${CMAKE_INSTALL_MANDIR} CACHE INTERNAL "Man files directory" FORCE)
    set(INSTALL_PKGCONFIG_DIR "${INSTALL_LIB_DIR}/pkgconfig" CACHE INTERNAL "Installation directory for pkgconfig (.pc) files" FORCE)
    set(INSTALL_CMAKECONF_DIR ${CMAKE_INSTALL_DATADIR}/${PROJECT_NAME}/CMake CACHE INTERNAL "Installation directory for cmake config files" FORCE)
endif()

include(util)
# Version information
check_version(PROJECT_VERSION_MAJOR PROJECT_VERSION_MINOR PROJECT_VERSION_MICRO PROJECT_VERSION_FULL PROJECT_VERSION_NUM)
set(VERSION "${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_MICRO}")
if(OSX_FRAMEWORK)
    set(FRAMEWORK_VERSION "${PROJECT_VERSION_MAJOR}")

    set(INSTALL_MAN_DIR ${INSTALL_LIB_DIR}/${PROJECT_NAME}.framework/Versions/${FRAMEWORK_VERSION}/Resources/man CACHE INTERNAL "Man files directory" FORCE)
endif()
report_version(${PROJECT_NAME} ${VERSION})

# TODO: Need to change ${name} value if ${name}_OPT changes
macro(ADD_OPTION name text value)
    option(${name}_OPT ${text} ${value})
    if(${value})
        set(${name} 1)
    else()
        set(${name} 0)
    endif()
    # message("set(${name} ${${name}})")
endmacro()

add_option(WITH_TRIO "Enable TRIO string manipulator" OFF)
add_option(WITH_THREADS "Add multithread support" ON)
add_option(WITH_THREAD_ALLOC "add per-thread memory" OFF)
add_option(WITH_TREE "Enable tree api" ON)
add_option(WITH_OUTPUT "Enable serialization support" ON)
add_option(WITH_PUSH "Enable push api" ON)
add_option(WITH_READER "Enable xmlReader api" ON)
add_option(WITH_PATTERN "Enable xmlPattern api" ON)
add_option(WITH_WRITER "Enable xmlWriter api" ON)
add_option(WITH_SAX1 "Enable SAX1 api" ON)
add_option(WITH_FTP "Enable FTP client" ON)
add_option(WITH_HTTP "Enable HTTP client" ON)
add_option(WITH_VALID "Enable DTD validation support" ON)
add_option(WITH_HTML "Add the HTML support" ON)
add_option(WITH_LEGACY "Enable deprecated APIs" ON)
add_option(WITH_C14N "Enable C14N support" ON)
add_option(WITH_CATALOG "Enable catalog support" ON)
add_option(WITH_DOCB "Enable DocBook support" ON)
add_option(WITH_XPATH "Enable XPath support" ON)
add_option(WITH_XPTR "Enable XPointer support" ON)
add_option(WITH_XINCLUDE "Enable XInclude support" ON)
add_option(WITH_ICU "Add ICU support" OFF)
add_option(WITH_ISO8859X "Enable iso8859x support" ON)
add_option(WITH_DEBUG "add the debugging module" ON)
add_option(WITH_MEM_DEBUG "add the memory debugging module" OFF)
add_option(WITH_RUN_DEBUG "add the runtime debugging module" OFF)
add_option(WITH_REGEXPS "Enable regular expressions" ON)
add_option(WITH_SCHEMAS "Enable XML Schema support" ON)
add_option(WITH_SCHEMATRON "Add Schematron support" ON)
add_option(WITH_MODULES "Add the dynamic modules support" ON)
add_option(WITH_WALKER "Enable xmlDocWalker api" ON)
add_option(WITH_PYTHON "Build Python bindings" OFF)
add_option(WITH_FEXCEPTIONS "Add GCC flag -fexceptions for C++ exceptions" OFF)
add_option(WITH_HISTORY "add history support to xmllint shell" OFF)
add_option(WITH_COVERAGE "build for code coverage with GCC" OFF)

if(WITH_SCHEMAS)
    set(WITH_PATTERN 1)
    set(WITH_REGEXPS 1)
endif()

if(WITH_SCHEMATRON)
    set(WITH_PATTERN 1)
    set(WITH_TREE 1)
    set(WITH_XPATH 1)
endif()

if(WITH_READER)
    set(WITH_PUSH 1)
endif()

if(WITH_XPTR)
    set(WITH_XPATH 1)
endif()

include(FindAnyProject)

if(UNIX)
    set(MODULE_EXTENSION ".so")
elseif(WIN32)
    set(MODULE_EXTENSION ".dll")
    set(THREADS_W32 TRUE)
    add_definitions(-DHAVE_WIN32_THREADS -DWIN32)
    list(APPEND TARGET_LINK_LIB ws2_32.lib Secur32.lib)
    if (MSVC)
        add_definitions (-D_CRT_NONSTDC_NO_DEPRECATE -D_CRT_SECURE_NO_WARNINGS -D_CRT_NON_CONFORMING_SWPRINTFS -D_CRT_SECURE_NO_DEPRECATE)
    endif()
endif()

if(WITH_THREADS)
    find_package(Threads REQUIRED)
    list(APPEND TARGET_LINK_LIB ${CMAKE_THREAD_LIBS_INIT})
    if(THREADS_FOUND)
        add_definitions(-DLIBXML_THREAD_ENABLED)
    endif()
endif()

find_anyproject(ZLIB)
if(ZLIB_FOUND)
    set(WITH_ZLIB 1)
    add_definitions(-DHAVE_ZLIB_H)
else()
    set(WITH_ZLIB 0)
endif()
find_anyproject(ICONV)
if(ICONV_FOUND)
    set(WITH_ICONV 1)
    add_definitions(-DHAVE_ICONV_H)
else()
    set(WITH_ICONV 0)
endif()
find_anyproject(LibLZMA)
if(LIBLZMA_FOUND)
    set(WITH_LZMA 1)
    add_definitions(-DHAVE_LZMA_H)
else()
    set(WITH_LZMA 0)
endif()

include(configure)

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/cmake/cmake_uninstall.cmake.in ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake IMMEDIATE @ONLY)

include_directories ( ${CMAKE_CURRENT_SOURCE_DIR}/include/ )
include_directories ( ${CMAKE_CURRENT_SOURCE_DIR} )
include_directories ( ${CMAKE_CURRENT_BINARY_DIR}/include/ )
include_directories ( ${CMAKE_CURRENT_BINARY_DIR} )

set(PUBLIC_HDRS
    libxml.h
)

set(PUBLIC_HDRS_LIBXML2
    ${CMAKE_CURRENT_BINARY_DIR}/include/libxml/xmlversion.h
    include/libxml/chvalid.h
    include/libxml/dict.h
    include/libxml/encoding.h
    include/libxml/entities.h
    include/libxml/globals.h
    include/libxml/hash.h
    include/libxml/list.h
    include/libxml/parser.h
    include/libxml/parserInternals.h
    include/libxml/pattern.h
    include/libxml/relaxng.h
    include/libxml/SAX2.h
    include/libxml/schemasInternals.h
    include/libxml/threads.h
    include/libxml/tree.h
    include/libxml/uri.h
    include/libxml/valid.h
    include/libxml/xinclude.h
    include/libxml/xlink.h
    include/libxml/xmlautomata.h
    include/libxml/xmlerror.h
    include/libxml/xmlexports.h
    include/libxml/xmlIO.h
    include/libxml/xmlmemory.h
    include/libxml/xmlmodule.h
    include/libxml/xmlreader.h
    include/libxml/xmlregexp.h
    include/libxml/xmlsave.h
    include/libxml/xmlstring.h
    include/libxml/xmlunicode.h
    include/libxml/xmlwriter.h
    include/libxml/xpath.h
    include/libxml/xpathInternals.h
    include/libxml/xpointer.h
)

set(PRIVATE_HDRS
    ${CMAKE_CURRENT_BINARY_DIR}/config.h
    triodef.h
    trionan.h
    xzlib.h
)

set(SRCS
    entities.c
    encoding.c
    error.c
    parserInternals.c
    parser.c
    SAX2.c
    tree.c
    hash.c
    list.c
    xmlIO.c
    xmlmemory.c
    uri.c
    valid.c
    xlink.c
    xpath.c
    xpointer.c
    xinclude.c
    globals.c
    threads.c
    xmlstring.c
    buf.c
    xmlregexp.c
    xmlunicode.c
    xmlreader.c
    relaxng.c
    dict.c
    xmlwriter.c
    legacy.c
    chvalid.c
    pattern.c
    xmlsave.c
    xmlmodule.c
    schematron.c
    xzlib.c
)

if(WITH_DOCB)
    set(SRCS ${SRCS}
        DOCBparser.c
    )
    set(PUBLIC_HDRS_LIBXML2 ${PUBLIC_HDRS_LIBXML2}
    include/libxml/DOCBparser.h
    )
endif()

if(WITH_C14N)
    set(SRCS ${SRCS}
        c14n.c
    )
    set(PUBLIC_HDRS_LIBXML2 ${PUBLIC_HDRS_LIBXML2}
        include/libxml/c14n.h
    )
endif()

if(WITH_CATALOG)
    set(SRCS ${SRCS}
        catalog.c
    )
    set(PUBLIC_HDRS_LIBXML2 ${PUBLIC_HDRS_LIBXML2}
        include/libxml/catalog.h
    )
endif()

if(WITH_HTML)
    set(SRCS ${SRCS}
        HTMLparser.c
        HTMLtree.c
    )
    set(PUBLIC_HDRS_LIBXML2 ${PUBLIC_HDRS_LIBXML2}
        include/libxml/HTMLparser.h
        include/libxml/HTMLtree.h
    )
endif()

if(WITH_SCHEMAS)
    set(SRCS ${SRCS}
        xmlschemas.c
        xmlschemastypes.c
    )
    set(PUBLIC_HDRS_LIBXML2 ${PUBLIC_HDRS_LIBXML2}
        include/libxml/xmlschemas.h
        include/libxml/xmlschemastypes.h
    )
endif()

if(WITH_SAX1)
    set(SRCS ${SRCS}
        SAX.c
    )
    set(PUBLIC_HDRS_LIBXML2 ${PUBLIC_HDRS_LIBXML2}
        include/libxml/SAX.h
    )
endif()

if(WITH_DEBUG)
    set(SRCS ${SRCS}
        debugXML.c
    )
    set(PUBLIC_HDRS_LIBXML2 ${PUBLIC_HDRS_LIBXML2}
        include/libxml/debugXML.h
    )
endif()

if(WITH_HTTP)
    set(SRCS ${SRCS}
        nanohttp.c
    )
    set(PUBLIC_HDRS_LIBXML2 ${PUBLIC_HDRS_LIBXML2}
        include/libxml/nanohttp.h
    )
endif()

if(WITH_FTP)
    set(SRCS ${SRCS}
        nanoftp.c
    )
    set(PUBLIC_HDRS_LIBXML2 ${PUBLIC_HDRS_LIBXML2}
        include/libxml/nanoftp.h
    )
endif()

if(WIN32)
    set(SRCS ${SRCS}
        # include/win32config.h wince stuf
        include/wsockcompat.h
    )

    # generate def file
    execute_process(COMMAND ${CMAKE_C_COMPILER} /P /EP /I${CMAKE_CURRENT_BINARY_DIR}/include /I${CMAKE_CURRENT_SOURCE_DIR}/include
        ${CMAKE_CURRENT_SOURCE_DIR}/win32/libxml2.def.src
    )
    file(STRINGS ${CMAKE_CURRENT_BINARY_DIR}/libxml2.def.i DEFS)
    set(DEF_SRC)
    foreach(DEF ${DEFS})
        if(DEF AND NOT DEF STREQUAL "" AND NOT DEF STREQUAL "xmlDllMain")
            set(DEF_SRC "${DEF_SRC}
${DEF}")
        endif()
    endforeach()
    file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/libxml2.def "${DEF_SRC}")
    set(SRCS ${SRCS}
        ${CMAKE_CURRENT_BINARY_DIR}/libxml2.def
    )
endif()

set(LIB_NAME lib${PROJECT_NAME})

if(BUILD_SHARED_LIBS)
    add_library(${LIB_NAME} SHARED ${SRCS} ${PUBLIC_HDRS} ${PUBLIC_HDRS_LIBXML2} ${PRIVATE_HDRS})
    if(MSVC)
        set_target_properties(${LIB_NAME} PROPERTIES IMPORT_SUFFIX "_i.lib")
    endif()

    set_target_properties (${LIB_NAME} PROPERTIES
        VERSION ${VERSION}
        DEFINE_SYMBOL XML2_DLL)
elseif(OSX_FRAMEWORK)
    add_library(${LIB_NAME} SHARED ${SRCS} ${PUBLIC_HDRS} ${PUBLIC_HDRS_LIBXML2} ${PRIVATE_HDRS})
    set_property(SOURCE ${PUBLIC_HDRS_LIBXML2}
        PROPERTY MACOSX_PACKAGE_LOCATION "Headers/libxml"
    )
    set_target_properties(${LIB_NAME} PROPERTIES
        FRAMEWORK TRUE
        FRAMEWORK_VERSION "${FRAMEWORK_VERSION}"
        VERSION ${VERSION}
        MACOSX_FRAMEWORK_SHORT_VERSION_STRING ${VERSION}
        MACOSX_FRAMEWORK_BUNDLE_VERSION ${VERSION}
        MACOSX_FRAMEWORK_IDENTIFIER org.xmlsoft.libxml2
        XCODE_ATTRIBUTE_INSTALL_PATH "@rpath"
        PUBLIC_HEADER "${PUBLIC_HDRS}")
else()
    add_definitions(-DXML2_STATIC)
    add_library(${LIB_NAME} STATIC ${SRCS} ${PUBLIC_HDRS} ${PUBLIC_HDRS_LIBXML2} ${PRIVATE_HDRS})
endif()

target_link_extlibraries(${LIB_NAME})

set(PACKAGE_NAME ${PROJECT_NAME})
string(TOUPPER ${PACKAGE_NAME} PACKAGE_UPPER_NAME)

if(NOT SKIP_INSTALL_LIBRARIES AND NOT SKIP_INSTALL_ALL )
    install(TARGETS ${LIB_NAME}
        EXPORT ${PACKAGE_UPPER_NAME}Targets
        RUNTIME DESTINATION ${INSTALL_BIN_DIR}
        LIBRARY DESTINATION ${INSTALL_LIB_DIR}
        ARCHIVE DESTINATION ${INSTALL_LIB_DIR}
        INCLUDES DESTINATION ${INSTALL_INC_DIR}
        FRAMEWORK DESTINATION ${INSTALL_LIB_DIR}
    )
endif()

if(NOT SKIP_INSTALL_HEADERS AND NOT SKIP_INSTALL_ALL )
    install(FILES ${PUBLIC_HDRS} DESTINATION "${INSTALL_INC_DIR}"  COMPONENT headers)
    install(FILES ${PUBLIC_HDRS_LIBXML2} DESTINATION "${INSTALL_INC_DIR}/libxml"  COMPONENT headers)
endif()


# Testing ======================================================================
enable_testing()
if(BUILD_TESTING)
    if(WIN32)
        # TODO: Works only for precompiled versions
        file(GLOB_RECURSE IMPORTED_WIN_DLLS ${CMAKE_BINARY_DIR}/third-party/install/*.dll)
        foreach(IMPORTED_WIN_DLL ${IMPORTED_WIN_DLLS})
            add_custom_command(TARGET ${LIB_NAME}
                                POST_BUILD
                                COMMAND ${CMAKE_COMMAND} -E copy ${IMPORTED_WIN_DLL} $<TARGET_FILE_DIR:${LIB_NAME}>
                                COMMENT "Copy ${IMPORTED_WIN_DLL}"
                            )
        endforeach()
    endif()

    file(COPY test DESTINATION ${CMAKE_CURRENT_BINARY_DIR})

    set(check_PROGRAMS
        testSchemas testRelax testSAX testHTML testXPath #testURI
        # testC14N
        testAutomata # testRegexp testReader
        testModule runsuite testchar
        testdict runxmlconf testrecurse testlimits
    )

    if(WIN32)
        set(check_PROGRAMS ${check_PROGRAMS} testThreadsWin32)
    else()
        set(check_PROGRAMS ${check_PROGRAMS} testThreads testapi runtest)
    endif()

    macro(XML2_TEST name)
        add_executable(${name} ${name}.c)
        target_link_libraries(${name} ${LIB_NAME})
        add_test(${name} ${name})
    endmacro()

    foreach(TEST ${check_PROGRAMS})
        xml2_test(${TEST})
    endforeach()

endif()

# uninstall
add_custom_target(uninstall COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake)

# Export package ===============================================================

# Add path to includes to build-tree export
target_include_directories(${LIB_NAME} INTERFACE
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
  $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/include>
  $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
)

# Add all targets to the build-tree export set
export(TARGETS ${LIB_NAME}
    FILE ${PROJECT_BINARY_DIR}/${PACKAGE_UPPER_NAME}Targets.cmake)

if(REGISTER_PACKAGE)
    # Export the package for use from the build-tree
    # (this registers the build-tree with a global CMake-registry)
    export(PACKAGE ${PACKAGE_UPPER_NAME})
endif()

# Create the <Package>Config.cmake file
configure_file(cmake/PackageConfig.cmake.in
    ${PROJECT_BINARY_DIR}/${PACKAGE_UPPER_NAME}Config.cmake @ONLY)

if(NOT SKIP_INSTALL_LIBRARIES AND NOT SKIP_INSTALL_ALL)
    # Install the <Package>Config.cmake
    install(FILES
      ${PROJECT_BINARY_DIR}/${PACKAGE_UPPER_NAME}Config.cmake
      DESTINATION ${INSTALL_CMAKECONF_DIR} COMPONENT dev)

    # Install the export set for use with the install-tree
    install(EXPORT ${PACKAGE_UPPER_NAME}Targets DESTINATION ${INSTALL_CMAKECONF_DIR} COMPONENT dev)
endif()

# Archiving ====================================================================

set(CPACK_PACKAGE_NAME "${PACKAGE_NAME}")
set(CPACK_PACKAGE_VENDOR "${PACKAGE_VENDOR}")
set(CPACK_PACKAGE_VERSION "${VERSION}")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "${PACKAGE_NAME} Installation")
set(CPACK_PACKAGE_RELOCATABLE TRUE)
set(CPACK_ARCHIVE_COMPONENT_INSTALL ON)
set(CPACK_GENERATOR "ZIP")
set(CPACK_MONOLITHIC_INSTALL ON)
set(CPACK_STRIP_FILES TRUE)

# Get cpack zip archive name
get_cpack_filename(${VERSION} PROJECT_CPACK_FILENAME)
set(CPACK_PACKAGE_FILE_NAME ${PROJECT_CPACK_FILENAME})

include(CPack)
