# add library rtl87x2g-init for zboss initialization
add_library(rtl87x2g-init STATIC
    "${REALTEK_SDK_ROOT}/bsp/boot/rtl87x2g/startup_rtl.c"
    system_rtl.c
    zb_main.c
    main_ns.c
    dbg_printf.c
)

set_target_properties(
    rtl87x2g-init
    PROPERTIES
        C_STANDARD 99
        CXX_STANDARD 11
)

target_compile_definitions(rtl87x2g-init
    PUBLIC
        ${COMMON_PLATFORM_DEFINES}
        "BUILD_WITHOUT_FTL=1"
        "RT_PLATFORM_RTL87X2G"
)

if(${OT_CMAKE_NINJA_TARGET} STREQUAL "ot-ncp-ftd")
    target_compile_definitions(rtl87x2g-init PUBLIC "BUILD_NCP=1")
endif()
if(${OT_CMAKE_NINJA_TARGET} STREQUAL "ot-ncp-mtd")
    target_compile_definitions(rtl87x2g-init PUBLIC "BUILD_NCP=1")
endif()
if(${OT_CMAKE_NINJA_TARGET} STREQUAL "ot-rcp")
    target_compile_definitions(rtl87x2g-init PUBLIC "BUILD_RCP=1")
endif()

target_compile_options(rtl87x2g-init
    PRIVATE
        ${OT_CFLAGS}
        -Wno-attributes
)

target_include_directories(rtl87x2g-init
    PRIVATE
        ${OT_PUBLIC_INCLUDES}
        ${OT_REALTEK_ROOT}/src/core
        ${OT_REALTEK_ROOT}/openthread/examples/platforms
        ${OT_REALTEK_ROOT}/src
        ${REALTEK_SDK_INCPATH}
        ${REALTEK_SDK_ROOT}/subsys/mac_driver
        ${REALTEK_SDK_ROOT}/subsys/mac_driver/portable/rtl87x2g
        ${CMAKE_CURRENT_SOURCE_DIR}/${BUILD_TARGET}
        ${CMAKE_CURRENT_SOURCE_DIR}/common
        ${REALTEK_SDK_ROOT}/subsys/usb/usb_hal/inc
        ${REALTEK_SDK_ROOT}/subsys/usb/usb_lib/inc/class
        ${REALTEK_SDK_ROOT}/subsys/usb/usb_lib/inc/composite
        ${REALTEK_SDK_ROOT}/subsys/mbedtls/port/inc
)

target_link_libraries(rtl87x2g-init
    PRIVATE
        ot-config
        ${OT_MBEDTLS}
)

add_custom_command(
    TARGET rtl87x2g-init
    POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E make_directory ${REALTEK_SDK_ROOT}/subsys/openthread/build/lib
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
            ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/librtl87x2g-init.a
            ${REALTEK_SDK_ROOT}/subsys/openthread/build/lib/librtl87x2g-init.a
    COMMENT "Copying librtl87x2g-init.a to build/lib/"
)
