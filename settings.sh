#!/bin/sh

ANDROID_SDK_ROOT="/opt/android_sdk/android-sdk-linux"
ANDROID_NDK_ROOT="/opt/android_ndk/android-ndk-r15b"

PLATFORMS="
          android-16
          android-17
          android-18
          android-19
          android-21
          android-22
          android-23
          android-24
          android-26
          android-27
          "

ARCHITECTURES="arm x86"

# Number of compilation processes during building of each package:
JOBS=$(nproc 2>/dev/null || echo 1)
# JOBS=4

# Default list of packages:
LOCAL_PKG_LIST="openssl"

# Delete unpacked source files after successful build of the package (true/false):
CLEAN_SRC_DIR=true

# Delete files from "build/" sub-directory after successful build of the package (true/false):
CLEAN_BUILD_DIR=true

# Override or add extra settings:
EXTRA_SETTINGS_FILE=$(ls "${MAIN_DIR}"/settings.sh.* 2> /dev/null | sort -V | tail -n1)
[ ! -z "${EXTRA_SETTINGS_FILE}" ] && . "${EXTRA_SETTINGS_FILE}" || true

