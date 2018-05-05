#!/bin/bash
#
# This file is part of aplump project. See LICENSE file for licensing information.

export MAIN_DIR="$(dirname $(realpath -s ${0}))"

# Setup

cd "${MAIN_DIR}"
. "${MAIN_DIR}/settings.sh"
. "${MAIN_DIR}/tools/define-paths.sh"
. "${MAIN_DIR}/tools/util.sh"

# Help, version, clean up an full clean up
if [ "${1}" = "help" ]
then
    echo \
"Usage: make [option] [package 1] [package 2] [package 3] ...

Options:
    list            display the list of available packages
    download        download sources without build of packages
    install-ndk     copy unpacked Android NDK to target location
    install-sdk     copy unpacked Android SDK to target location
    install         copy all built extra libraries into Android NDK
    clean           clean up (delete android-ndk-extra-libs/ subdirectory with all files)
    distclean       full clean up (delete android-ndk-extra-libs/ and src/ subdirectories with all files)
    version         display project version and exit
    help            display this help and exit

Examples:
    make android-ndk android-sdk
    make
    make all
    make openssl freeglut
    make \"download\"
    make \"download all\"
    make \"download ffmpeg sdl2\"
    make install
    make clean
    make distclean

Settings:
    Edit file settings.sh or add file settings.sh.<any-suffix>
"
    exit 0
elif [ "${1}" = "version" ]
then
    if [ -d "${MAIN_DIR}/.git" ] && which git &>/dev/null
    then
        git describe --tags
    elif [ -e "${MAIN_DIR}/changelog" ]
    then
        grep '^--- ' "${MAIN_DIR}/changelog" | head -n1 | \
            sed -ne "s|^--- \(.*\) ---$|\1|p"
    else
        echo "Version can not be determined!"
        echo "Clone original git repo or copy original"\
             "tarball with sources of this project."
        exit 1
    fi
    exit 0
elif [ "${1}" = "install-ndk" ]
then
    cd "${MAIN_DIR}"
    SUBDIR="$(ls -d android-ndk-r* 2> /dev/null | sort -V | tail -n1)"
    if [ -z "${SUBDIR}" ]
    then
        echo "Error! Directory with Android NDK is not found!"
        echo "Make sure that you have downloaded and unpacked it using of:"
        echo "make android-ndk"
        exit 1
    fi
    echo "cp -afT \"${MAIN_DIR}/${SUBDIR}\" \"${ANDROID_NDK_ROOT}\""
    cp -afT "${MAIN_DIR}/${SUBDIR}" "${ANDROID_NDK_ROOT}"
    exit 0
elif [ "${1}" = "install-sdk" ]
then
    cd "${MAIN_DIR}"
    SUBDIR="$(ls -d android-sdk* 2> /dev/null | sort -V | tail -n1)"
    if [ -z "${SUBDIR}" ]
    then
        echo "Error! Directory with Android SDK is not found!"
        echo "Make sure that you have downloaded and unpacked it using of:"
        echo "make android-sdk"
        exit 1
    fi
    echo "cp -afT \"${MAIN_DIR}/${SUBDIR}\" \"${ANDROID_SDK_ROOT}\""
    cp -afT "${MAIN_DIR}/${SUBDIR}" "${ANDROID_SDK_ROOT}"
    exit 0
elif [ "${1}" = "install" ]
then
    echo "cp -af \"${MAIN_DIR}/android-ndk-extra-libs\"/* \"${ANDROID_NDK_ROOT}/\""
    cp -af "${MAIN_DIR}/android-ndk-extra-libs"/* "${ANDROID_NDK_ROOT}/"
    exit 0
elif [ "${1}" = "list" ]
then
    grep 'PKG=' "${MAIN_DIR}/pkg"/*.sh | sed -ne "s|.*pkg/\(.*\)\.sh:.*|\1|p"
    exit 0
elif [ "${1}" = "clean" ]
then
    cd "${MAIN_DIR}" || exit 1
    for DEL_DIR in "android-ndk-extra-libs" "installed" "log" "tmp-build" "tmp-src"
    do
        [ -d "${MAIN_DIR}/${DEL_DIR}" ] || continue
        echo "rm -rf \"${MAIN_DIR}/${DEL_DIR}\""
        rm -rf "${MAIN_DIR}/${DEL_DIR}"
    done
    exit 0
elif [ "${1}" = "distclean" ]
then
    "${MAIN_DIR}/make.sh" clean
    if [ -d "${MAIN_DIR}/src" ]
    then
        echo "rm -rf \"${MAIN_DIR}/src\""
        rm -rf "${MAIN_DIR}/src"
    fi
    exit 0
elif [ "${1}" = "download" ]
then
    export DOWNLOAD_ONLY="true"
fi

# Make packages

BuildPackages()
{
    if [ ! -z "${1}" ]
    then
        if [ "${1}" = "all" ]
        then
            BuildAllPackages
        elif [ "${1}" = "download" ]
        then
            if [ "${2}" = "all" ]
            then
                BuildAllPackages
            elif [ ! -z "${2}" ]
            then
                BuildPackagesFromOptions ${@}
            else
                BuildPackagesFromSettings
            fi
        else
            BuildPackagesFromOptions ${@}
        fi
    elif [ ! -z "${LOCAL_PKG_LIST}" ]
    then
        BuildPackagesFromSettings
    fi
}

BuildAllPackages()
{
    for ARG in $(${0} list)
    do
        IsOption "${ARG}" && continue || true
        IsIgnoredPackage "${ARG}" && continue || true
        if [ -e "${MAIN_DIR}/pkg/${ARG}.sh" ]
        then
            . "${MAIN_DIR}/pkg/${ARG}.sh" || exit 1
        else
            echo "Package ${ARG} does not exist!"
            exit 1
        fi
    done
}

BuildPackagesFromOptions()
{
    for ARG in ${@}
    do
        IsOption "${ARG}" && continue || true
        if [ -e "${MAIN_DIR}/pkg/${ARG}.sh" ]
        then
            . "${MAIN_DIR}/pkg/${ARG}.sh" || exit 1
        else
            echo "Package ${ARG} does not exist!"
            exit 1
        fi
    done
}

BuildPackagesFromSettings()
{
    for ARG in ${LOCAL_PKG_LIST}
    do
        if [ -e "${MAIN_DIR}/pkg/${ARG}.sh" ]
        then
            . "${MAIN_DIR}/pkg/${ARG}.sh" || exit 1
        else
            echo "Package ${ARG} does not exist!"
            exit 1
        fi
    done
}

for PLATFORM in ${PLATFORMS}
do
    if [ ! -d "${ANDROID_NDK_ROOT}/platforms/${PLATFORM}" ]
    then
        echo "Platform ${PLATFORM} does not exist!"
        exit 1
    fi

    for ARCH in ${ARCHITECTURES}
    do
        DefinePaths
        [ -d "${ANDROID_SYSROOT}" ] || continue

        PrepareDirs
        BuildPackages ${@}
    done
done

