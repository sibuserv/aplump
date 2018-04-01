#!/bin/sh
#
# This file is part of aplump project. See LICENSE file for licensing information.

(
    PKG=x264
    PKG_VERSION=20180404-2245
    PKG_CHECKSUM=4192860e28cd01fb6d7de563fb1eb770b2b5f8bcf27bbc5f630aca3cbacb5295
    PKG_SUBDIR=${PKG}-${PKG_VERSION}
    PKG_SUBDIR_ORIG=${PKG}-snapshot-${PKG_VERSION}
    PKG_FILE=${PKG}-snapshot-${PKG_VERSION}.tar.bz2
    PKG_URL="https://download.videolan.org/pub/videolan/x264/snapshots/${PKG_FILE}"
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

