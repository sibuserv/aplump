#!/bin/sh

ORIG_PATH="${PATH}"

DefinePaths()
{
    ANDROID_SYSROOT="${ANDROID_NDK_ROOT}/platforms/${PLATFORM}/arch-${ARCH}"
    SYSROOT="${ANDROID_NDK_ROOT}/sysroot"
    PREFIX="${MAIN_DIR}/android-ndk-extra-libs/platforms/${PLATFORM}/arch-${ARCH}"
    PKG_DIR="${MAIN_DIR}/pkg"
    SRC_DIR="${MAIN_DIR}/src"
    PKG_SRC_DIR="${MAIN_DIR}/tmp-src"
    BUILD_DIR="${MAIN_DIR}/tmp-build"
    LOG_DIR="${MAIN_DIR}/log/${PLATFORM}_${ARCH}"
    INST_DIR="${MAIN_DIR}/installed/${PLATFORM}_${ARCH}"
}

