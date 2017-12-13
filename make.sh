#!/bin/bash

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
    install         copy all built extra libs into Android NDK
    clean           clean up (delete android-ndk-extra-libs/ subdirectory with all files)
    distclean       full clean up (delete android-ndk-extra-libs/ and src/ subdirectories with all files)
    version         display project version and exit
    help            display this help and exit

Examples:
    make
    make openssl freeglut
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
elif [ "${1}" = "install" ] && [ -z "${2}" ]
then
    echo "cp -af \"${MAIN_DIR}/android-ndk-extra-libs\"/* \"${ANDROID_NDK_ROOT}/\""
    cp -af "${MAIN_DIR}/android-ndk-extra-libs"/* "${ANDROID_NDK_ROOT}/"
    exit 0
elif [ "${1}" = "list" ]
then
    grep 'PKG=' "${MAIN_DIR}/pkg"/*.sh | sed -ne "s|.*pkg/\(.*\)\.sh:.*|\1|p"
    exit 0
elif [ "${1}" = "clean" ] && [ -z "${2}" ]
then
    cd "${MAIN_DIR}" || exit 1
    for DEL_DIR in "android-ndk-extra-libs" "installed" "log" "tmp-build" "tmp-src"
    do
        [ -d "${MAIN_DIR}/${DEL_DIR}" ] || continue
        echo "rm -rf \"${MAIN_DIR}/${DEL_DIR}\""
        rm -rf "${MAIN_DIR}/${DEL_DIR}"
    done
    exit 0
elif [ "${1}" = "distclean" ] && [ -z "${2}" ]
then
    "${MAIN_DIR}/make.sh" clean
    if [ -d "${MAIN_DIR}/src" ]
    then
        echo "rm -rf \"${MAIN_DIR}/src\""
        rm -rf "${MAIN_DIR}/src"
    fi
    exit 0
fi

# Make packages

BuildPackages()
{
    if [ ! -z "${1}" ]
    then
        for ARG in ${@}
        do
            if [ -e "${MAIN_DIR}/pkg/${ARG}.sh" ]
            then
                . "${MAIN_DIR}/pkg/${ARG}.sh" || exit 1
            else
                echo "Package ${ARG} does not exist!"
                exit 1
            fi
        done
    elif [ ! -z "${LOCAL_PKG_LIST}" ]
    then
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
    fi
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
        BuildPackages
    done
done

rmdir --ignore-fail-on-non-empty "${PKG_SRC_DIR}"   &> /dev/null
rmdir --ignore-fail-on-non-empty "${BUILD_DIR}"     &> /dev/null

