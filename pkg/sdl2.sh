#!/bin/sh

(
    PKG=sdl2
    PKG_VERSION=43bba409e6d2
    PKG_CHECKSUM=3ad7878d650f8619d952139638f9ea8f63f4a86f0b926376c4e0770a134fb6f9
    PKG_SUBDIR=${PKG}-${PKG_VERSION}
    #PKG_SUBDIR_ORIG=SDL2-${PKG_VERSION}
    PKG_SUBDIR_ORIG=SDL-${PKG_VERSION}
    PKG_FILE=${PKG_SUBDIR_ORIG}.tar.gz
    #PKG_URL="http://www.libsdl.org/release/${PKG_FILE}"
    PKG_URL="https://hg.libsdl.org/SDL/archive/${PKG_VERSION}.tar.gz"
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

        unset CFLAGS CPPFLAGS CXXFLAGS LDFLAGS
        ConfigureCmakeProject \
            -DCMAKE_TOOLCHAIN_FILE="${ANDROID_NDK_ROOT}/build/cmake/android.toolchain.cmake" \
            -DCMAKE_INSTALL_PREFIX="${PREFIX}/usr" \
            -DANDROID_TOOLCHAIN="gcc" \
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

