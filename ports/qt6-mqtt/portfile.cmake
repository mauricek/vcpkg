include(vcpkg_common_functions)

if (WIN32)
    # ###TODO: ugly ugly hack
    # we need to add bin to PATH to find zlib1.dll for the host tools
    # however hyperscan does something similar
    message(STATUS "Instdir: ${CURRENT_INSTALLED_DIR}")
    vcpkg_add_to_path(${CURRENT_INSTALLED_DIR}/bin)
    vcpkg_add_to_path(${CURRENT_INSTALLED_DIR}/debug/bin)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO qt/qtmqtt
#    REF TODO We have no stable release yet to rely on. Potentially sync with COIN once there?
#    SHA512 TODO Check REF
    HEAD_REF wip/cmake
)

#Find and add Perl to PATH
vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_EXE_PATH ${PERL} DIRECTORY)
vcpkg_add_to_path("${PERL_EXE_PATH}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTING=OFF
        -DBUILD_EXAMPLES=OFF
)

vcpkg_build_cmake(
    LOGFILE_ROOT build
    )

vcpkg_install_cmake()

# We might loose debug features
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)


# The post install steps are bit blurry right now. Basing here on qt5-base/portfile.cmake
# and trying to shut up error messages from vcpkg for now
#file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share)
#file(RENAME ${CURRENT_PACKAGES_DIR}/lib/cmake ${CURRENT_PACKAGES_DIR}/share/cmake)
#file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/cmake/Qt6/QtBuildInternals)
#file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)

#from qt_install_copyright
if(EXISTS "${SOURCE_PATH}/LICENSE.LGPLv3")
    set(LICENSE_PATH "${SOURCE_PATH}/LICENSE.LGPLv3")
elseif(EXISTS "${SOURCE_PATH}/LICENSE.LGPL3")
    set(LICENSE_PATH "${SOURCE_PATH}/LICENSE.LGPL3")
elseif(EXISTS "${SOURCE_PATH}/LICENSE.GPLv3")
    set(LICENSE_PATH "${SOURCE_PATH}/LICENSE.GPLv3")
elseif(EXISTS "${SOURCE_PATH}/LICENSE.GPL3")
    set(LICENSE_PATH "${SOURCE_PATH}/LICENSE.GPL3")
elseif(EXISTS "${SOURCE_PATH}/LICENSE.GPL3-EXCEPT")
    set(LICENSE_PATH "${SOURCE_PATH}/LICENSE.GPL3-EXCEPT")
endif()

file(INSTALL ${LICENSE_PATH} DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
