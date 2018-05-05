#!/bin/sh
#
# This file is part of aplump project. See LICENSE file for licensing information.

(
    # https://developer.android.com/ndk/downloads/index.html
    PKG=android-ndk
    PKG_VERSION=r15b
    PKG_CHECKSUM=d1ce63f68cd806b5a992d4e5aa60defde131c243bf523cdfc5b67990ef0ee0d3
    PKG_SUBDIR=${PKG}-${PKG_VERSION}
    PKG_FILE=android-ndk-${PKG_VERSION}-linux-x86_64.zip
    PKG_URL="https://dl.google.com/android/repository/${PKG_FILE}"
    PKG_DEPS=""

    CheckSourcesAndDependencies

    if [ ! -d "${MAIN_DIR}/${PKG_SUBDIR}" ]
    then
        echo "[unpack]   ${PKG_FILE}"
        UnpackSources

        echo "[copy]     ${PKG_SUBDIR}"
        cp -a "${PKG_SRC_DIR}/${PKG_SUBDIR}" "${MAIN_DIR}/"

        CleanPkgSrcDir
        EndOfPkgBuild
    fi
)

