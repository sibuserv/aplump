#!/bin/sh
#
# This file is part of aplump project. See LICENSE file for licensing information.

(
    # https://developer.android.com/studio/index.html#downloads
    PKG=android-sdk
    PKG_VERSION=r25.2.5
    PKG_CHECKSUM=577516819c8b5fae680f049d39014ff1ba4af870b687cab10595783e6f22d33e
    PKG_SUBDIR=android-sdk-linux
    PKG_SUBDIR_ORIG=tools
    PKG_FILE=tools_${PKG_VERSION}-linux.zip
    PKG_URL="https://dl.google.com/android/repository/${PKG_FILE}"
    PKG_DEPS=""

    if [ ! -d "${MAIN_DIR}/${PKG_SUBDIR}/${PKG_SUBDIR_ORIG}" ]
    then
        CheckDependencies
        GetSources "quiet"

        echo "[unpack]   ${PKG_FILE}"
        UnpackSources

        echo "[copy]     ${PKG_SUBDIR}"
        mkdir -p "${MAIN_DIR}/${PKG_SUBDIR}"
        cp -a "${PKG_SRC_DIR}/${PKG_SUBDIR_ORIG}" "${MAIN_DIR}/${PKG_SUBDIR}/"

        CleanPkgSrcDir
        EndOfPkgBuild
    fi
)

