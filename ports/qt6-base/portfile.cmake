include(vcpkg_common_functions)
# currently built with:
# vcpkg install --triplet x64-windows --head --no-downloads qt6-base

# qt6 requires cmake 3.15, cherry pick this
# https://github.com/microsoft/vcpkg/pull/7801

if (WIN32)
    # ###TODO: ugly ugly hack
    # we need to add bin to PATH to find zlib1.dll for the host tools.
    # However, hyperscan does something similar
    vcpkg_add_to_path(${CURRENT_INSTALLED_DIR}/bin)
    vcpkg_add_to_path(${CURRENT_INSTALLED_DIR}/debug/bin)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO qt/qtbase
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
 #   TARGET Core # Used to speed up testing
    )

vcpkg_install_cmake()

# We need to get the tools to a different directory, other than bin.
# Following to that we could specify this directory at vcpkg_copy_tool_dependencies()
# and be done. Let's check upstream.

function(qt_install_tool TOOL_PATH)
    set (TARGET_TOOL ${TOOL_PATH})
    if (WIN32)
        set (TARGET_TOOL "${TARGET_TOOL}.exe")
    endif()

    #file(COPY ${CURRENT_PACKAGES_DIR}/bin/${TARGET_TOOL} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/qt6-base/${TARGET_TOOL})
    file(COPY ${CURRENT_PACKAGES_DIR}/bin/${TARGET_TOOL} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/qt6-base)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/${TARGET_TOOL})
endfunction()

qt_install_tool(androiddeployqt)
qt_install_tool(moc)
qt_install_tool(qdbuscpp2xml)
qt_install_tool(qdbusxml2cpp)
qt_install_tool(qlalr)
qt_install_tool(qmake)
qt_install_tool(qt-cmake)
qt_install_tool(qvkgen)
qt_install_tool(rcc)
qt_install_tool(tracegen)
qt_install_tool(uic)
# release should be empty now and debug should not be required
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/qt6-base)

# This directory gets created, but is empty on a non developer build
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/cmake/Qt6/QtBuildInternals)

# We might loose debug features
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)


# The post install steps are bit blurry right now. Basing here on qt5-base/portfile.cmake
# and trying to shut up error messages from vcpkg for now
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share)
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/cmake ${CURRENT_PACKAGES_DIR}/share/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/cmake/Qt6/QtBuildInternals)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)

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

# TODO: We are still missing the whole Qt relocation part, which makes building other modules
# troublesome.
