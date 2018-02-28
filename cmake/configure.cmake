################################################################################
# Project:  Lib XML2
# Purpose:  CMake build scripts
# Author:   Dmitry Baryshnikov, dmitry.baryshnikov@nexgis.com
################################################################################
# Copyright (C) 2015, NextGIS <info@nextgis.com>
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

# Include all the necessary files for macros
include (CheckFunctionExists)
include (CheckIncludeFile)
include (CheckIncludeFiles)
include (CheckLibraryExists)
include (CheckSymbolExists)
include (CheckTypeSize)
include (TestBigEndian)
include (CheckCSourceCompiles)
include (CheckStructHasMember)

if(CMAKE_GENERATOR_TOOLSET MATCHES "v([0-9]+)_xp")
    add_definitions(-D_WIN32_WINNT=0x0501)
endif()

check_include_files("dirent.h" HAVE_DIRENT_H)
check_include_file("ctype.h" HAVE_CTYPE_H)
check_include_file("stdlib.h" HAVE_STDLIB_H)
if(HAVE_CTYPE_H AND HAVE_STDLIB_H)
    set(STDC_HEADERS 1)
endif()

check_include_files("fcntl.h" HAVE_FCNTL_H)
check_include_files("unistd.h" HAVE_UNISTD_H)
check_include_files("errno.h" HAVE_ERRNO_H)
check_include_files("malloc.h" HAVE_MALLOC_H)
check_include_files("stdarg.h" HAVE_STDARG_H)
check_include_files("sys/stat.h" HAVE_SYS_STAT_H)
check_include_files("sys/types.h" HAVE_SYS_TYPES_H)
check_include_files("stdint.h" HAVE_STDINT_H)
check_include_files("inttypes.h" HAVE_INTTYPES_H)
check_include_files("time.h" HAVE_TIME_H)
check_include_files("ansidecl.h" HAVE_ANSIDECL_H)
check_include_files("ieeefp.h" HAVE_IEEEFP_H)
check_include_files("nan.h" HAVE_NAN_H)
check_include_files("math.h" HAVE_MATH_H)
check_include_files("limits.h" HAVE_LIMITS_H)
check_include_files("fp_class.h" HAVE_FP_CLASS_H)
check_include_files("float.h" HAVE_FLOAT_H)
check_include_files("sys/socket.h" HAVE_SYS_SOCKET_H)
check_include_files("netinet/in.h" HAVE_NETINET_IN_H)
check_include_files("arpa/inet.h" HAVE_ARPA_INET_H)
check_include_files("netdb.h" HAVE_NETDB_H)
check_include_files("sys/time.h" HAVE_SYS_TIME_H)
check_include_files("sys/select.h" HAVE_SYS_SELECT_H)
check_include_files("poll.h" HAVE_POLL_H)
check_include_files("sys/mman.h" HAVE_SYS_MMAN_H)
check_include_files("sys/timeb.h" HAVE_SYS_TIMEB_H)
check_include_files("signal.h" HAVE_SIGNAL_H)
check_include_files("arpa/nameser.h" HAVE_ARPA_NAMESER_H)
check_include_files("resolv.h" HAVE_RESOLV_H)
check_include_files("dl.h" HAVE_DL_H)
check_include_files("dlfcn.h" HAVE_DLFCN_H)

check_type_size(uint32_t SIZEOF_UINT32_T)

check_function_exists("strftime" HAVE_STRFTIME)
check_function_exists("strdup" HAVE_STRDUP)
check_function_exists("strerror" HAVE_STRERROR)
check_function_exists("strndup" HAVE_STRNDUP)
check_function_exists("finite" HAVE_FINITE)
check_function_exists("isascii" HAVE_ISASCII)
check_function_exists("isinf" HAVE_ISINF)
check_function_exists("isnan" HAVE_ISNAN)
check_function_exists("isnand" HAVE_ISNAND)

check_function_exists("fp_class" HAVE_FP_CLASS)
check_function_exists("fpclass" HAVE_FPCLASS)
check_function_exists("class" HAVE_CLASS)

check_function_exists("localtime" HAVE_LOCALTIME)
check_function_exists("gettimeofday" HAVE_GETTIMEOFDAY)
check_function_exists("ftime" HAVE_FTIME)

check_function_exists("stat" HAVE_STAT)
check_function_exists("_stat" HAVE__STAT)
check_function_exists("signal" HAVE_SIGNAL)
check_function_exists("rand" HAVE_RAND)
check_function_exists("rand_r" HAVE_RAND_R)

check_function_exists("mmap" HAVE_MMAP)
check_function_exists("munmap" HAVE_MUNMAP)
check_function_exists("putenv" HAVE_PUTENV)

check_c_source_compiles("
    #include <stdarg.h>
    va_list ap1,ap2;
    int main ()
    {
        va_copy(ap1,ap2);
        return 0;
    }" HAVE_VA_COPY)


check_c_source_compiles("
    #include <stdarg.h>
    void a(va_list * ap) {}
    int main(void) {
        va_list ap1, ap2;
        a(&ap1);
        ap2 = (va_list) ap1;
        return 0;
    }
    " VA_LIST_IS_ARRAY)

check_function_exists("gethostent" HAVE_GETHOSTENT)
check_function_exists("setsockopt" HAVE_SETSOCKOPT)
check_function_exists("connect" HAVE_CONNECT)
check_symbol_exists("socklen_t" "sys/socket.h" HAVE_SOCKLEN_T)

check_c_source_compiles("
    #include <netdb.h>
    int
    main ()
    {
    (void)gethostbyname((const char *)\"\");
      ;
      return 0;
    }" HAVE_GETHOSTBYNAME_ARG_CAST)

if(NOT HAVE_GETHOSTBYNAME_ARG_CAST)
    set(GETHOSTBYNAME_ARG_CAST "(char *)")
endif()
add_definitions(-DGETHOSTBYNAME_ARG_CAST=${GETHOSTBYNAME_ARG_CAST})

check_c_source_compiles("
    #include <sys/types.h>
    #include <sys/socket.h>
    int
    main ()
    {
    (void)send(1,(const char *)\"\",1,1);
      ;
      return 0;
    }" HAVE_SEND_ARG2_CAST)

if(NOT HAVE_SEND_ARG2_CAST)
    set(SEND_ARG2_CAST "(char *)")
endif()
add_definitions(-DSEND_ARG2_CAST=${SEND_ARG2_CAST})

#check_function_exists("__va_copy" HAVE___VA_COPY)
check_c_source_compiles("
    #include <stdarg.h>
    va_list ap1,ap2;
    int main ()
    {
        __va_copy(ap1,ap2);
        return 0;
    }" HAVE___VA_COPY)

# test it
check_struct_has_member("struct sockaddr" __ss_family "sys/socket.h" HAVE_BROKEN_SS_FAMILY)

check_include_files("ctyper.h" HAVE_CTYPE_H)
check_function_exists("dlopen" HAVE_DLOPEN)
check_function_exists("fprintf" HAVE_FPRINTF)
check_function_exists("getaddrinfo" HAVE_GETADDRINFO)

check_library_exists(history append_history "" HAVE_LIBHISTORY)
check_library_exists(readline readline "" HAVE_LIBREADLINE)

check_include_files("memory.h" HAVE_MEMORY_H)
check_include_files("ndir.h" HAVE_NDIR_H)

check_function_exists("printf" HAVE_PRINTF)
check_function_exists("vprintf" HAVE_VPRINTF)

check_include_files("pthread.h" HAVE_PTHREAD_H)

check_function_exists("shl_load" HAVE_SHLLOAD)

check_function_exists("snprintf" HAVE_SNPRINTF)
check_function_exists("sprintf" HAVE_SPRINTF)
check_function_exists("srand" HAVE_SRAND)
check_function_exists("scanf" HAVE_SCANF)
check_function_exists("fscanf" HAVE_FSCANF)
check_function_exists("sscanf" HAVE_SSCANF)

check_include_files("strings.h" HAVE_STRINGS_H)
check_include_files("string.h" HAVE_STRING_H)

check_include_files("sys/dir.h" HAVE_SYS_DIR_H)
check_include_files("sys/ndir.h" HAVE_SYS_NDIR_H)

check_function_exists("time" HAVE_TIME)

check_function_exists("vfprintf" HAVE_VFPRINTF)
check_function_exists("vsnprintf" HAVE_VSNPRINTF)
check_function_exists("vsprintf" HAVE_VSPRINTF)

if(WITH_FEXCEPTIONS)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fexceptions")
endif()

if(ICONV_FOUND)
    set(HAVE_ICONV ${ICONV_FOUND} CACHE INTERNAL "enable POSIX iconv support")

    if(${ICONV_SECOND_ARGUMENT_IS_CONST})
        set(ICONV_CONST "const")
    endif()

    if(${ICONV_SECOND_ARGUMENT_CPP_IS_CONST})
        set(ICONV_CPP_CONST "const")
    endif()
    add_definitions(-DICONV_CONST=${ICONV_CONST})
    add_definitions(-DICONV_CPP_CONST=${ICONV_CPP_CONST})
endif()


if(WIN32)
    set(_WINSOCKAPI_ TRUE)
endif()


set(PACKAGE ${PROJECT_NAME})
set(PACKAGE_NAME "lib${PACKAGE}")
set(PACKAGE_VERSION ${VERSION})
set(PACKAGE_STRING "${PACKAGE_NAME} ${PACKAGE_VERSION}")

set(LIBXML_VERSION_NUMBER ${PROJECT_VERSION_NUM})
set(LIBXML_VERSION_EXTRA "")

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/cmake/config.h.in ${CMAKE_CURRENT_BINARY_DIR}/config.h IMMEDIATE @ONLY)
add_definitions(-DHAVE_CONFIG_H)
if(APPLE)
    configure_file(${CMAKE_CURRENT_SOURCE_DIR}/cmake/config.h.in ${CMAKE_CURRENT_BINARY_DIR}/config-mac.h IMMEDIATE @ONLY)
endif()

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/include/libxml/xmlversion.h.in ${CMAKE_CURRENT_BINARY_DIR}/include/libxml/xmlversion.h IMMEDIATE @ONLY )
if(UNIX)
    configure_file(${CMAKE_CURRENT_SOURCE_DIR}/xml2-config.in ${CMAKE_CURRENT_BINARY_DIR}/xml2-config IMMEDIATE @ONLY)
endif()
