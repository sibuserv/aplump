#!/bin/sh
#
# This file is part of aplump project. See LICENSE file for licensing information.

(
    PKG=x264
    PKG_VERSION=20180806-2245
    PKG_CHECKSUM=9f876c88aeb21fa9315e4a078931faf6fc0d3c3f47e05a306d2fdc62ea0afea2
    PKG_SUBDIR=${PKG}-${PKG_VERSION}
    PKG_SUBDIR_ORIG=${PKG}-snapshot-${PKG_VERSION}
    PKG_FILE=${PKG}-snapshot-${PKG_VERSION}.tar.bz2
    PKG_URL="https://download.videolan.org/pub/videolan/x264/snapshots/${PKG_FILE}"
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

        # IsStaticPackage && \
        #     LIB_TYPE_OPTS="--enable-static" || \
        #     LIB_TYPE_OPTS="--enable-shared"

        # For now ffmpeg for Android cannot be built with libx264 in a shared
        # library mode, so build it as static library:
        LIB_TYPE_OPTS="--enable-static"

        ConfigurePkg \
            --prefix="${PREFIX}/usr" \
            --sysroot="${ANDROID_SYSROOT}" \
            --cross-prefix="${ANDROID_TOOLCHAIN}/${TARGET}-" \
            --host="${TARGET}" \
            ${LIB_TYPE_OPTS} \
            --enable-pic \
            --disable-asm \
            --disable-cli

        BuildPkg -j ${JOBS}
        InstallPkg install

        UnsetCrossToolchainVariables
        CleanPkgBuildDir
        CleanPkgSrcDir
        CleanPrefixDir
    fi
)

