#!/bin/sh
#
# This file is part of aplump project. See LICENSE file for licensing information.

(
    PKG=freeglut
    PKG_VERSION=3.0.0
    PKG_CHECKSUM=2a43be8515b01ea82bcfa17d29ae0d40bd128342f0930cd1f375f1ff999f76a2
    PKG_SUBDIR=${PKG}-${PKG_VERSION}
    PKG_FILE=${PKG}-${PKG_VERSION}.tar.gz
    PKG_URL="https://sourceforge.net/projects/${PKG}/files/${PKG}/${PKG_VERSION}/${PKG_FILE}"
    PKG_DEPS=""

    if ! IsPkgInstalled
    then
        CheckDependencies

        GetSources
        UnpackSources
        PrepareBuild

        SetBuildFlags
        SetCrossToolchainVariables
        SetCrossToolchainPath

        # For now freeglut for Android cannot be used as a shared library:
        export CMAKE_STATIC_BOOL="ON"
        export CMAKE_SHARED_BOOL="OFF"

        ConfigureCmakeProject \
            -DCMAKE_TOOLCHAIN_FILE="${ANDROID_NDK_ROOT}/build/cmake/android.toolchain.cmake" \
            -DCMAKE_INSTALL_PREFIX="${PREFIX}/usr" \
            -DANDROID_TOOLCHAIN="gcc" \
            -DANDROID_PLATFORM="${ANDROID_PLATFORM}" \
            -DANDROID_ABI="${ANDROID_ABI}" \
            -DCMAKE_BUILD_TYPE="Release" \
            -DFREEGLUT_BUILD_SHARED_LIBS="${CMAKE_SHARED_BOOL}" \
            -DFREEGLUT_BUILD_STATIC_LIBS="${CMAKE_STATIC_BOOL}" \
            -DFREEGLUT_REPLACE_GLUT=ON \
            -DFREEGLUT_GLES=ON \
            -DFREEGLUT_BUILD_DEMOS=OFF

        BuildPkg -j ${JOBS}
        InstallPkg install

        UnsetCrossToolchainVariables
        CleanPkgBuildDir
        CleanPkgSrcDir
        CleanPrefixDir
    fi
)

