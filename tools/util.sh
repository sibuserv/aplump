#!/bin/bash
#
# This file is part of aplump project. See LICENSE file for licensing information.

PrepareDirs()
{
    mkdir -p "${PREFIX}"
    mkdir -p "${PREFIX}"
    mkdir -p "${PREFIX}/usr/lib"
    mkdir -p "${SRC_DIR}"
    mkdir -p "${PKG_SRC_DIR}"
    mkdir -p "${BUILD_DIR}"
    mkdir -p "${LOG_DIR}"
    mkdir -p "${INST_DIR}"
}

SetCrossToolchainPath()
{
    [ ! -z "${ANDROID_TOOLCHAIN}" ] || SetAndroidSpecificVariables
    export PATH="${ANDROID_TOOLCHAIN}:${ORIG_PATH}"

    if [ ! -d "${ANDROID_TOOLCHAIN}" ]
    then
        echo "Android toolchain \"${ANDROID_TOOLCHAIN}\" does not exist!"
        exit 1
    fi
}

SetSystemPath()
{
    export PATH="${ORIG_PATH}"
}

SetLibraryPath()
{
    export LIBRARY_PATH="${LIBRARY_PATH}:${PREFIX}/usr/lib"
}

UnsetLibraryPath()
{
    unset LIBRARY_PATH
}

UnsetMakeFlags()
{
    unset MAKEFLAGS
}

SetAndroidSpecificVariables()
{
    export ANDROID_NDK_SYSROOT="${ANDROID_SYSROOT}"
    export CROSS_SYSROOT="${ANDROID_SYSROOT}"
    export NDK_SYSROOT="${ANDROID_SYSROOT}"

    export ANDROID_PLATFORM="${PLATFORM}"
    export ANDROID_API="${PLATFORM}"
    export ANDROID_ARCH="arch-${ARCH}"

    if   [ "${ARCH}" = "arm" ] ; then
        export ANDROID_ABI="armeabi-v7a"
        export ANDROID_EABI="arm-linux-androideabi-4.9"
        export TARGET="arm-linux-androideabi"
        export MACHINE="armv7"
    elif [ "${ARCH}" = "arm64" ] ; then
        export ANDROID_ABI="arm64-v8a"
        export ANDROID_EABI="aarch64-linux-android-4.9"
        export TARGET="aarch64-linux-android"
        export MACHINE="armv8"
    elif [ "${ARCH}" = "mips" ] ; then
        export ANDROID_ABI="mips"
        export ANDROID_EABI="mipsel-linux-android-4.9"
        export TARGET="mipsel-linux-android"
        export MACHINE="mips"
    elif [ "${ARCH}" = "mips64" ] ; then
        export ANDROID_ABI="mips64"
        export ANDROID_EABI="mips64el-linux-android-4.9"
        export TARGET="mips64el-linux-android"
        export MACHINE="mips64"
    elif [ "${ARCH}" = "x86" ] ; then
        export ANDROID_ABI="x86"
        export ANDROID_EABI="i686-linux-android-4.9"
        export TARGET="i686-linux-android"
        export MACHINE="i686"
    elif [ "${ARCH}" = "x86_64" ] ; then
        export ANDROID_ABI="x86_64"
        export ANDROID_EABI="x86_64-linux-android-4.9"
        export TARGET="x86_64-linux-android"
        export MACHINE="x86_64"
    else
        export ANDROID_ABI="${ARCH}"
        export ANDROID_EABI="${ARCH}"
        export TARGET="${ARCH}-linux-android"
        export MACHINE="${ARCH}"
    fi

    # dirty fix because of irrational Android NDK developers
    if   [ "${ARCH}" = "x86" ] ; then
        local TOOLCHAIN="x86-4.9"
    elif [ "${ARCH}" = "x86_64" ] ; then
        local TOOLCHAIN="x86_64-4.9"
    else
        local TOOLCHAIN="${ANDROID_EABI}"
    fi
    # dirty fix because of irrational Qt SDK developers

    for HOST in "linux-x86_64" "linux-x86" "darwin-x86_64" "darwin-x86"
    do
        export HOST="${HOST}"
        export SYSTEM="android"
        export ANDROID_TOOLCHAIN="${ANDROID_NDK_ROOT}/toolchains/${TOOLCHAIN}/prebuilt/${HOST}/bin"
        [ -d "${ANDROID_TOOLCHAIN}" ] && break || true
    done
}

UnsetAndroidSpecificVariables()
{
    unset ANDROID_SYSROOT ANDROID_DEV ANDROID_TOOLCHAIN
    unset ANDROID_PLATFORM ANDROID_API ANDROID_ARCH ANDROID_ABI ANDROID_EABI
    unset TARGET HOST SYSTEM
}

SetCrossToolchainVariables()
{
    SetAndroidSpecificVariables

    export CROSS_COMPILE=${TARGET}-
    export cc=${CROSS_COMPILE}gcc
    export CC=${CROSS_COMPILE}gcc
    export cxx=${CROSS_COMPILE}g++
    export CXX=${CROSS_COMPILE}g++
    export AR=${CROSS_COMPILE}ar
    export AS=${CROSS_COMPILE}as
    export LD=${CROSS_COMPILE}ld
    export NM=${CROSS_COMPILE}nm
    export OBJCOPY=${CROSS_COMPILE}objcopy
    export OBJDUMP=${CROSS_COMPILE}objdump
    export RANLIB=${CROSS_COMPILE}ranlib
    export STRIP=${CROSS_COMPILE}strip

    export PKG_CONFIG_SYSROOT_DIR="/"
    export PKG_CONFIG_PATH="${PREFIX}/usr/lib/pkgconfig"
    export PKG_CONFIG_LIBDIR="${PREFIX}/usr/lib/pkgconfig"

    if IsStaticPackage
    then
        export CMAKE_STATIC_BOOL="ON"
        export CMAKE_SHARED_BOOL="OFF"
        export AUTOTOOLS_STATIC_STR="--enable-static"
        export AUTOTOOLS_SHARED_STR="--disable-shared"
    else
        export CMAKE_STATIC_BOOL="OFF"
        export CMAKE_SHARED_BOOL="ON"
        export AUTOTOOLS_STATIC_STR="--disable-static"
        export AUTOTOOLS_SHARED_STR="--enable-shared"
    fi
}

UnsetCrossToolchainVariables()
{
    UnsetAndroidSpecificVariables

    unset CROSS_COMPILE cc CC cpp CPP cxx CXX
    unset AR AS LD NM OBJCOPY OBJDUMP RANLIB STRIP
    unset PKG_CONFIG_SYSROOT_DIR PKG_CONFIG_PATH PKG_CONFIG_LIBDIR
}

SetBuildFlags()
{
    export CFLAGS="-s -Os -fPIC -fdata-sections -ffunction-sections -D_FORTIFY_SOURCE=2 -fstack-protector-strong"
    export CXXFLAGS="${CFLAGS} -std=c++11"
    export LDFLAGS="-Wl,--strip-all -Wl,--as-needed -Wl,-z,relro -Wl,--gc-sections"

    # export CFLAGS="${CFLAGS} -static-libgcc"
    # export CXXFLAGS="${CXXFLAGS} -static-libgcc -static-libstdc++"
}

CheckFail()
{
    if [ ! $? -eq 0 ]
    then
        tail -n 50 "${1}"
        exit 1
    fi
}

CheckDependencies()
{
    if [ ! -z "${PKG_DEPS}" ]
    then
        ( "${MAIN_DIR}/make.sh" ${PKG_DEPS} ) || exit 1
    fi
}

IsStaticPackage()
{
    for STATIC_PKG in ${STATIC_PKG_LIST}
    do
        [ "${STATIC_PKG}" = "${PKG}" ] && return 0 || true
    done
    return 1
}

IsVer1GreaterOrEqualToVer2()
{
    [ "${1}" = "$(echo -e "${1}\n${2}" | sort -V | tail -n1)" ] && \
        return 0 || \
        return 1
}

IsPkgVersionGreaterOrEqualTo()
{
    IsVer1GreaterOrEqualToVer2 "${PKG_VERSION}" "${1}" && \
        return 0 || \
        return 1
}

IsPkgInstalled()
{
    [ -e "${INST_DIR}/${PKG}" ] && \
        return 0 || \
        return 1
}

PrintSystemInfo()
{
    echo "[target]   ${PLATFORM}_${ARCH}"
}

BeginOfPkgBuild()
{
    echo "[build]    ${PKG}"
}

BeginDownload()
{
    echo "[download] ${PKG_FILE}"
}

EndOfPkgBuild()
{
    date -R > "${INST_DIR}/${PKG}"
    echo "[done]     ${PKG}"
}

CheckPkgUrl()
{
    if [ ! -z "${PKG_URL_2}" ]
    then
        local HTTP_REPLY=$(curl -L -I "${PKG_URL}" 2>/dev/null | grep 'HTTP/')
        if [ $(echo "${HTTP_REPLY}" | grep '404' | wc -l) != "0" ]
        then
            PKG_URL="${PKG_URL_2}"
        elif ! curl -L -I "${PKG_URL}" &> /dev/null
        then
            PKG_URL="${PKG_URL_2}"
        fi
        unset PKG_URL_2
    fi
}

IsTarballCheckRequired()
{
    local MUTABLE_TARBALLS_PKG_LIST=""

    for PKG_WITH_MUTABLE_TARBALL in ${MUTABLE_TARBALLS_PKG_LIST}
    do
        if [ "${PKG_WITH_MUTABLE_TARBALL}" = "${PKG}" ]
        then
            echo "[checksum] skip check of ${PKG_FILE}"
            return 1
        fi
    done
    return 0
}

GetSources()
{
    [ "${1}" != "quiet" ] && PrintSystemInfo

    local WGET="wget -v -c --no-config --no-check-certificate --max-redirect=50"
    local LOG_FILE="${LOG_DIR}/${PKG_SUBDIR}/tarball-download.log"
    mkdir -p "${LOG_DIR}/${PKG_SUBDIR}"
    cd "${SRC_DIR}"
    if [ ! -e "${PKG_FILE}" ]
    then
        BeginDownload
        CheckPkgUrl
        ${WGET} -o "${LOG_FILE}" -O "${PKG_FILE}" "${PKG_URL}"
        CheckFail "${LOG_FILE}"
    fi
    local TARBALL_CHECKSUM=$(openssl dgst -sha256 "${PKG_FILE}" 2>/dev/null | sed -n 's,^.*\([0-9a-f]\{64\}\)$,\1,p')
    if [ "${TARBALL_CHECKSUM}" != "${PKG_CHECKSUM}" ] && IsTarballCheckRequired
    then
        echo "[checksum] ${PKG_FILE}"
        echo "Error! Checksum mismatch:"
        echo "TARBALL_CHECKSUM = ${TARBALL_CHECKSUM}"
        echo "PKG_CHECKSUM     = ${PKG_CHECKSUM}"
        echo "Try to remove tarball to force build system to download it again:"
        echo "rm \"${SRC_DIR}/${PKG_FILE}\""
        exit 1
    fi

    BeginOfPkgBuild
}

UnpackSources()
{
    set -e
    cd "${PKG_SRC_DIR}"
    [ ! -z "${PKG_SUBDIR_ORIG}" ] && \
            local SUBDIR="${PKG_SUBDIR_ORIG}" || \
            local SUBDIR="${PKG_SUBDIR}"

    if [ ! -d "${SUBDIR}" ]
    then
        cp -a "${SRC_DIR}/${PKG_FILE}" .
        if [[ "${PKG_FILE}" == *.zip ]]
        then
            unzip -q "${PKG_FILE}"
        else
            tar xf "${PKG_FILE}"
        fi
        rm "${PKG_FILE}"

        local PATCH_FILE="${PKG_DIR}/${PKG}-${PKG_VERSION}.patch"
        if [ -e "${PATCH_FILE}" ] || [ -h "${PATCH_FILE}" ]
        then
            local LOG_FILE="${LOG_DIR}/${PKG_SUBDIR}/patch.log"
            cd "${PKG_SRC_DIR}/${SUBDIR}"
            patch -p1 -i "${PATCH_FILE}" &> "${LOG_FILE}"
        fi
        local PATCH_SCRIPT="${MAIN_DIR}/pkg/${PKG}-patches.sh"
        if [ -e "${PATCH_SCRIPT}" ] || [ -h "${PATCH_SCRIPT}" ]
        then
            . "${PATCH_SCRIPT}"
        fi
    fi
    set +e
}

PrepareBuild()
{
    mkdir -p "${BUILD_DIR}/${PKG_SUBDIR}"
    cd "${LOG_DIR}/${PKG_SUBDIR}"
    rm -f configure.log make.log make-install.log

    UnsetMakeFlags
}

CopySrcAndPrepareBuild()
{
    if [ -z "${PKG_SUBDIR_ORIG}" ]
    then 
        cp -afT "${PKG_SRC_DIR}/${PKG_SUBDIR}" "${BUILD_DIR}/${PKG_SUBDIR}"
    else
        cp -afT "${PKG_SRC_DIR}/${PKG_SUBDIR_ORIG}" "${BUILD_DIR}/${PKG_SUBDIR}"
    fi
    cd "${LOG_DIR}/${PKG_SUBDIR}"
    rm -f configure.log make.log make-install.log

    UnsetMakeFlags
}

ConfigurePkg()
{
    local LOG_FILE="${LOG_DIR}/${PKG_SUBDIR}/configure.log"
    cd "${BUILD_DIR}/${PKG_SUBDIR}"
    if [ -z "${PKG_SUBDIR_ORIG}" ]
    then
        "${PKG_SRC_DIR}/${PKG_SUBDIR}/configure" ${@} &>> "${LOG_FILE}"
    else
        "${PKG_SRC_DIR}/${PKG_SUBDIR_ORIG}/configure" ${@} &>> "${LOG_FILE}"
    fi
    CheckFail "${LOG_FILE}"
}

ConfigurePkgInBuildDir()
{
    local LOG_FILE="${LOG_DIR}/${PKG_SUBDIR}/configure.log"
    cd "${BUILD_DIR}/${PKG_SUBDIR}"
    ./configure ${@} &>> "${LOG_FILE}"
    CheckFail "${LOG_FILE}"
}

ConfigureAutotoolsProject()
{
    ConfigurePkg \
        --prefix="${PREFIX}/usr" \
        ${@}
}

ConfigureAutotoolsProjectInBuildDir()
{
    ConfigurePkgInBuildDir \
        --prefix="${PREFIX}/usr" \
        ${@}
}

ConfigureCmakeProject()
{
    local LOG_FILE="${LOG_DIR}/${PKG_SUBDIR}/configure.log"
    cd "${BUILD_DIR}/${PKG_SUBDIR}"
    if [ -z "${PKG_SUBDIR_ORIG}" ]
    then
        cmake "${PKG_SRC_DIR}/${PKG_SUBDIR}" "${@}" &>> "${LOG_FILE}"
    else
        cmake "${PKG_SRC_DIR}/${PKG_SUBDIR_ORIG}" "${@}" &>> "${LOG_FILE}"
    fi
    CheckFail "${LOG_FILE}"
}

BuildPkg()
{
    local LOG_FILE="${LOG_DIR}/${PKG_SUBDIR}/make.log"
    cd "${BUILD_DIR}/${PKG_SUBDIR}"
    make ${@} &>> "${LOG_FILE}"
    CheckFail "${LOG_FILE}"
}

InstallPkg()
{
    local LOG_FILE="${LOG_DIR}/${PKG_SUBDIR}/make-install.log"
    cd "${BUILD_DIR}/${PKG_SUBDIR}"
    make ${@} &>> "${LOG_FILE}"
    CheckFail "${LOG_FILE}"

    DeleteExtraFiles
    EndOfPkgBuild
}

CleanPkgSrcDir()
{
    if [ "${CLEAN_SRC_DIR}" = "true" ]
    then
        [ -z "${PKG_SUBDIR_ORIG}" ] && \
            rm -rf "${PKG_SRC_DIR}/${PKG_SUBDIR}" || \
            rm -rf "${PKG_SRC_DIR}/${PKG_SUBDIR_ORIG}"
    fi
}

CleanPkgBuildDir()
{
    if [ "${CLEAN_BUILD_DIR}" = "true" ]
    then
        rm -rf "${BUILD_DIR}/${PKG_SUBDIR}"
    fi
}

CleanPrefixDir()
{
    find "${PREFIX}/usr" -depth -empty -delete
}

DeleteExtraFiles()
{
    find "${PREFIX}/usr/lib" -type f -name '*.la' -exec rm -f {} \;
}

