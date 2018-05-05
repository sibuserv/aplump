#!/bin/sh
#
# This file is part of aplump project. See LICENSE file for licensing information.

(
    PKG=ffmpeg
    PKG_VERSION=3.4.2
    PKG_CHECKSUM=eb0370bf223809b9ebb359fed5318f826ac038ce77933b3afd55ab1a0a21785a
    PKG_SUBDIR=${PKG}-${PKG_VERSION}
    PKG_FILE=${PKG_SUBDIR}.tar.bz2
    PKG_URL="https://www.ffmpeg.org/releases/${PKG_FILE}"
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

        ConfigurePkg \
            --prefix="${PREFIX}/usr" \
            --sysroot="${ANDROID_SYSROOT}" \
            --extra-cflags="-I\"${PREFIX}/usr/include\"" \
            --extra-cxxflags="-I\"${PREFIX}/usr/include\"" \
            --extra-ldflags="-L\"${PREFIX}/usr/lib\"" \
            ${AUTOTOOLS_STATIC_STR} \
            ${AUTOTOOLS_SHARED_STR} \
            --arch="${ARCH}" \
            --cross-prefix="${TARGET}-" \
            --enable-cross-compile \
            --target-os=android \
            --enable-avisynth \
            --enable-avresample \
            --enable-pic \
            --enable-gpl \
            --disable-debug \
            --disable-doc \
            --disable-libass \
            --disable-libbluray \
            --disable-libbs2b \
            --disable-libcaca \
            --disable-libmp3lame \
            --disable-libopencore-amrnb \
            --disable-libopencore-amrwb \
            --disable-libopus \
            --disable-libspeex \
            --disable-libtheora \
            --disable-libvidstab \
            --disable-libvo-amrwbenc \
            --disable-libvorbis \
            --disable-libvpx \
            --disable-libx264 \
            --disable-libxvid \
            --disable-programs \
            --disable-iconv \
            --disable-openssl \
            --disable-gnutls \
            --disable-schannel \
            --disable-securetransport \
            --disable-x86asm

        BuildPkg -j ${JOBS}
        InstallPkg install

        rm -rf "${PREFIX}/usr/share/ffmpeg/"

        UnsetCrossToolchainVariables
        CleanPkgBuildDir
        CleanPkgSrcDir
        CleanPrefixDir
    fi
)

