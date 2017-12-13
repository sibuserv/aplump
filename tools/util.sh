#!/bin/bash

PrepareDirs()
{
    mkdir -p "${PREFIX}"
    mkdir -p "${SYSROOT}"
    mkdir -p "${SYSROOT}/usr/lib"
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
    export LIBRARY_PATH="${LIBRARY_PATH}:${SYSROOT}/usr/lib"
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
    unset ANDROID_API ANDROID_ARCH ANDROID_ABI ANDROID_EABI
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
    export PKG_CONFIG_PATH="${SYSROOT}/usr/lib/pkgconfig"
    export PKG_CONFIG_LIBDIR="${SYSROOT}/usr/lib/pkgconfig"
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

BeginOfPkgBuild()
{
    echo "[target]   ${PLATFORM}_${ARCH}"
    echo "[build]    ${PKG}"
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
        if [ $(curl -I "${PKG_URL}" 2>/dev/null | grep '404 Not Found' | wc -l) != "0" ]
        then
            PKG_URL="${PKG_URL_2}"
        elif ! curl -I "${PKG_URL}" &> /dev/null
        then
            PKG_URL="${PKG_URL_2}"
        fi
        unset PKG_URL_2
    fi
}

GetSources()
{
    BeginOfPkgBuild

    local WGET="wget -v -c --no-config --no-check-certificate --max-redirect=50"
    local LOG_FILE="${LOG_DIR}/${PKG_SUBDIR}/tarball-download.log"
    local TARBALL_SIZE="${LOG_DIR}/${PKG_SUBDIR}/tarball-size.info"
    mkdir -p "${LOG_DIR}/${PKG_SUBDIR}"
    cd "${SRC_DIR}"
    if [ ! -e "${PKG_FILE}" ]
    then
        CheckPkgUrl
        local SIZE=$(curl -I "${PKG_URL}" 2>&1 | sed -ne "s|^Content-Length: \(.*\)$|\1|p")
        echo "${SIZE}" > "${TARBALL_SIZE}"
        ${WGET} -o "${LOG_FILE}" -O "${PKG_FILE}" "${PKG_URL}"
        CheckFail "${LOG_FILE}"
    elif [ -e "${TARBALL_SIZE}" ]
    then
        CheckPkgUrl
        local SIZE=$(cat "${TARBALL_SIZE}")
        local FILE_SIZE=$(curl -I "file:${SRC_DIR}/${PKG_FILE}" 2>&1 | sed -ne "s|^Content-Length: \(.*\)$|\1|p")
        if [ "${FILE_SIZE}" != "${SIZE}" ]
        then
            ${WGET} -o "${LOG_FILE}" -O "${PKG_FILE}" "${PKG_URL}"
            CheckFail "${LOG_FILE}"
        fi
    fi
    local TARBALL_CHECKSUM=$(openssl dgst -sha256 "${PKG_FILE}" 2>/dev/null | sed -n 's,^.*\([0-9a-f]\{64\}\)$,\1,p')
    if [ "${TARBALL_CHECKSUM}" != "${PKG_CHECKSUM}" ]
    then
        echo "Error! Checksum mismatch:"
        echo "TARBALL_CHECKSUM = ${TARBALL_CHECKSUM}"
        echo "PKG_CHECKSUM     = ${PKG_CHECKSUM}"
        exit 1
    fi
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
        if [ -e "${MAIN_DIR}/pkg/${PKG}-patches.sh" ]
        then
            . "${MAIN_DIR}/pkg/${PKG}-patches.sh"
        elif [ -h "${MAIN_DIR}/pkg/${PKG}-patches.sh" ]
        then
            . "${MAIN_DIR}/pkg/${PKG}-patches.sh"
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
        --prefix="${SYSROOT}/usr" \
        ${@}
}

ConfigureAutotoolsProjectInBuildDir()
{
    ConfigurePkgInBuildDir \
        --prefix="${SYSROOT}/usr" \
        ${@}
}

ConfigureCmakeProject()
{
    local LOG_FILE="${LOG_DIR}/${PKG_SUBDIR}/configure.log"
    cd "${BUILD_DIR}/${PKG_SUBDIR}"
    if [ -z "${PKG_SUBDIR_ORIG}" ]
    then
        "${PREFIX}/bin/${TARGET}-cmake" "${PKG_SRC_DIR}/${PKG_SUBDIR}" "${@}" &>> "${LOG_FILE}"
    else
        "${PREFIX}/bin/${TARGET}-cmake" "${PKG_SRC_DIR}/${PKG_SUBDIR_ORIG}" "${@}" &>> "${LOG_FILE}"
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

DeleteExtraFiles()
{
    find "${SYSROOT}/usr/lib" -type f -name '*.la' -exec rm -f {} \;
}

