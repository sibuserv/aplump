#!/bin/sh
#
# This file is part of aplump project. See LICENSE file for licensing information.

(
    PKG=sdl2
    PKG_VERSION=2.0.9
    PKG_CHECKSUM=255186dc676ecd0c1dbf10ec8a2cc5d6869b5079d8a38194c2aecdff54b324b1
    PKG_SUBDIR=${PKG}-${PKG_VERSION}
    PKG_SUBDIR_ORIG=SDL2-${PKG_VERSION}
    PKG_FILE=${PKG_SUBDIR_ORIG}.tar.gz
    PKG_URL="https://www.libsdl.org/release/${PKG_FILE}"
    PKG_DEPS=""

    CheckSourcesAndDependencies

    if IsBuildRequired
    then
        PrintSystemInfo
        BeginOfPkgBuild
        UnpackSources
        PrepareBuild

        SetBuildFlags
        SetCrossToolchainVariables
        SetCrossToolchainPath

        unset CFLAGS CPPFLAGS CXXFLAGS LDFLAGS
        ConfigureCmakeProject \
            -DCMAKE_TOOLCHAIN_FILE="${ANDROID_NDK_ROOT}/build/cmake/android.toolchain.cmake" \
            -DCMAKE_INSTALL_PREFIX="${PREFIX}/usr" \
            -DANDROID_TOOLCHAIN="clang" \
            -DANDROID_PLATFORM="${ANDROID_PLATFORM}" \
            -DANDROID_ABI="${ANDROID_ABI}" \
            -DCMAKE_BUILD_TYPE="Release" \
            -DSDL_SHARED="${CMAKE_SHARED_BOOL}" \
            -DSDL_STATIC="${CMAKE_STATIC_BOOL}"

        BuildPkg -j ${JOBS}
        InstallPkg install

        rm -f "${PREFIX}/usr/bin/sdl2-config"
        rm -f "${PREFIX}/usr/share/aclocal/sdl2.m4"

        UnsetCrossToolchainVariables
        CleanPkgBuildDir
        CleanPkgSrcDir
        CleanPrefixDir
    fi
)

