IF(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
    ADD_DEFINITIONS(-DOS_LINUX -DOS_POSIX)
ELSEIF(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
    ADD_DEFINITIONS(-DOS_MAC -DOS_POSIX)
ELSEIF(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
    ADD_DEFINITIONS(-D_WIN32 -DOS_WIN)
ELSE()
    MESSAGE(FATAL_ERROR "Not supported OS: "${CMAKE_SYSTEM_NAME})
ENDIF()

MESSAGE(STATUS "CMAKE_SYSTEM_PROCESSOR: ${CMAKE_SYSTEM_PROCESSOR}")
MESSAGE(STATUS "CMAKE_SYSTEM: ${CMAKE_SYSTEM}")

IF (CMAKE_BUILD_TYPE)
    STRING(TOUPPER ${CMAKE_BUILD_TYPE} CMAKE_BUILD_TYPE_STABLE) 
    MESSAGE(STATUS "CMAKE_BUILD_TYPE: ${CMAKE_BUILD_TYPE_STABLE}")
ENDIF(CMAKE_BUILD_TYPE)

SET(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_CURRENT_LIST_DIR}/")
IF(NOT CMAKE_DEBUG_POSTFIX)
    SET(CMAKE_DEBUG_POSTFIX d)
ENDIF()
INCLUDE(cmake/projecthelper.cmake)
INCLUDE(cmake/utils.cmake)

IF(OPENSSL_ENABLED)
    SET(OPENSSL_USE_STATIC ON)
    ADD_DEFINITIONS(-DOPENSSL_SUPPORT_ENABLED)
    
    FIND_PACKAGE(OpenSSL REQUIRED)
    
    IF(OPENSSL_FOUND)
        #SET(OPENSSL_LIBS optimized ${LIB_EAY_RELEASE} debug ${LIB_EAY_DEBUG} optimized ${SSL_EAY_RELEASE} debug ${SSL_EAY_DEBUG})
        GET_FILENAME_COMPONENT(OPENSSL_ROOT_DIR ${OPENSSL_INCLUDE_DIR} PATH)
    ELSE(OPENSSL_FOUND)
        IF(NOT OPENSSL_ROOT_DIR OR NOT EXISTS ${OPENSSL_ROOT_DIR})
       	    MESSAGE(FATAL_ERROR "OPENSSL_ENABLED but not founded, please specify OPENSSL_ROOT_DIR variable." )
        ENDIF()
        FILE(GLOB OPENSSL_LIBS "${OPENSSL_ROOT_DIR}/*.lib")
    ENDIF(OPENSSL_FOUND)
ENDIF(OPENSSL_ENABLED)

IF(SSH_ENABLED)
    ADD_DEFINITIONS(-DSSH_SUPPORT_ENABLED)
    IF(NOT OPENSSL_FOUND)
        MESSAGE(FATAL_ERROR "OPENSSH_ENABLED but openssl not founded, please specify OPENSSL_ROOT_DIR variable and check the OPENSSL_ENABLED variable must be ON.")
    ENDIF(NOT OPENSSL_FOUND)
ENDIF(SSH_ENABLED)

IF(BOOST_ENABLED)
    ADD_DEFINITIONS(-DBOOST_SUPPORT_ENABLED)
    INCLUDE(${CMAKE_CURRENT_LIST_DIR}/integrate-boost.cmake)
    SET(Boost_USE_MULTITHREADED     ON)
    SET(Boost_USE_STATIC_LIBS ON)
ENDIF(BOOST_ENABLED)

IF(UNICODE_ENABLED)
    IF(MINGW)
        SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}  -municode")
    ENDIF(MINGW)
    ADD_DEFINITIONS(-DUNICODE -D_UNICODE)
ENDIF(UNICODE_ENABLED)

IF(QT_ENABLED)
	INCLUDE(${CMAKE_CURRENT_LIST_DIR}/integrate-qt.cmake)
	ADD_DEFINITIONS(-DQT_SUPPORT_ENABLED)
ENDIF(QT_ENABLED)

IF(DEVELOPER_ENABLE_TESTS)
    INCLUDE(cmake/testing.cmake)
    SETUP_TESTING()
ENDIF(DEVELOPER_ENABLE_TESTS)

MACRO(ADD_APP_EXECUTABLE_MSVC PROJECT_NAME SOURCES LIBS)
	ADD_EXECUTABLE(${PROJECT_NAME} ${DESKTOP_TARGET} ${SOURCES})
	TARGET_LINK_LIBRARIES(${PROJECT_NAME} ${LIBS})
ENDMACRO()

MACRO(ADD_APP_LIBRARY_MSVC PROJECT_NAME SOURCES LIBS)
	ADD_LIBRARY(${PROJECT_NAME} STATIC ${SOURCES})
	TARGET_LINK_LIBRARIES(${PROJECT_NAME} ${LIBS} )
ENDMACRO()

MACRO(ADD_APP_EXECUTABLE PROJECT_NAME SOURCES LIBS)
    SET(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/${BUILD_TYPE}/build)
    SET(TARGET ${PROJECT_NAME})
    ADD_EXECUTABLE(${TARGET} ${DESKTOP_TARGET} ${SOURCES})
    TARGET_LINK_LIBRARIES(${TARGET} ${LIBS})
    IF ("${CMAKE_BUILD_TYPE_STABLE}" STREQUAL "RELEASE")
        SET_TARGET_PROPERTIES(${TARGET} PROPERTIES COMPILE_FLAGS "${CMAKE_CXX_FLAGS_RELEASE}")
    ELSE()
        SET_TARGET_PROPERTIES(${TARGET} PROPERTIES COMPILE_FLAGS "${CMAKE_CXX_FLAGS_DEBUG}")
    ENDIF()
ENDMACRO()

MACRO(ADD_APP_LIBRARY PROJECT_NAME SOURCES LIBS)
    SET(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/${BUILD_TYPE}/build)
    SET(TARGET ${PROJECT_NAME})
    ADD_LIBRARY(${TARGET} STATIC ${SOURCES})
    TARGET_LINK_LIBRARIES(${TARGET} ${LIBS})
    IF ("${CMAKE_BUILD_TYPE_STABLE}" STREQUAL "RELEASE")
        SET_TARGET_PROPERTIES(${TARGET} PROPERTIES COMPILE_FLAGS "${CMAKE_CXX_FLAGS_RELEASE}")
    ELSE()
        SET_TARGET_PROPERTIES(${TARGET} PROPERTIES COMPILE_FLAGS "${CMAKE_CXX_FLAGS_DEBUG}")
    ENDIF()
ENDMACRO()
