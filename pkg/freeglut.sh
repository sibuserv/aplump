#!/bin/sh

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

        ConfigureCmakeProject \
            -DCMAKE_TOOLCHAIN_FILE="${ANDROID_NDK_ROOT}/build/cmake/android.toolchain.cmake" \
            -DCMAKE_INSTALL_PREFIX="${PREFIX}/usr" \
            -DANDROID_TOOLCHAIN="gcc" \
            -DFREEGLUT_BUILD_SHARED_LIBS=OFF \
            -DFREEGLUT_BUILD_STATIC_LIBS=ON \
            -DFREEGLUT_REPLACE_GLUT=ON \
            -DFREEGLUT_GLES=ON \
            -DFREEGLUT_BUILD_DEMOS=OFF

        BuildPkg -j ${JOBS}
        InstallPkg install

        CleanPkgBuildDir
        CleanPkgSrcDir
    fi
)

