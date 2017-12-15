#!/bin/sh

(
    PKG=ffmpeg
    PKG_VERSION=3.4.1
    PKG_CHECKSUM=f3443e20154a590ab8a9eef7bc951e8731425efc75b44ff4bee31d8a7a574a2c
    PKG_SUBDIR=${PKG}-${PKG_VERSION}
    PKG_FILE=${PKG_SUBDIR}.tar.bz2
    PKG_URL="http://www.ffmpeg.org/releases/${PKG_FILE}"
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
        # dirty workaround for Android NDK r16 and later
        export ANDROID_API_VER="$(echo ${PLATFORM} | tr -d android-)"
        # export CC="${CC} '-D__ANDROID_API__=${ANDROID_API_VER}' -I'${SYSROOT}/usr/include' -I'${SYSROOT}/usr/include/${TARGET}'"
        export CFLAGS="-I'${SYSROOT}/usr/include' -I'${SYSROOT}/usr/include/${TARGET}'"
        export CXXFLAGS="-I'${SYSROOT}/usr/include' -I'${SYSROOT}/usr/include/${TARGET}'"
        # end of dirty workaround
        ConfigurePkg \
            --prefix="${PREFIX}/usr" \
            --sysroot="${ANDROID_SYSROOT}" \
            --enable-static \
            --disable-shared \
            --arch="${ARCH}" \
            --cross-prefix="${TARGET}-" \
            --enable-cross-compile \
            --target-os=android \
            --enable-avisynth \
            --enable-avresample \
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

        rm -rf "${PREFIX}/usr/share/ffmpeg"

        UnsetCrossToolchainVariables
        CleanPkgBuildDir
        CleanPkgSrcDir
    fi
)

