#!/bin/sh
#
# This file is part of aplump project. See LICENSE file for licensing information.

(
    PKG=openssl
    PKG_VERSION=1.0.2o
    PKG_SUBVERSION=1.0.2
    PKG_CHECKSUM=ec3f5c9714ba0fd45cb4e087301eb1336c317e0d20b575a125050470e8089e4d
    PKG_SUBDIR=${PKG}-${PKG_VERSION}
    PKG_FILE=${PKG}-${PKG_VERSION}.tar.gz
    PKG_URL="ftp://ftp.openssl.org/source/${PKG_FILE}"
    PKG_URL_2="ftp://ftp.openssl.org/source/old/${PKG_SUBVERSION}/${PKG_FILE}"
    PKG_DEPS=""

    if ! IsPkgInstalled
    then
        CheckDependencies

        GetSources
        UnpackSources
        CopySrcAndPrepareBuild

        SetBuildFlags
        SetCrossToolchainVariables
        SetCrossToolchainPath

        cd "${BUILD_DIR}/${PKG_SUBDIR}"
        ln -sf "Configure" "configure"
        unset CC
        export ANDROID_DEV="${ANDROID_SYSROOT}/usr"
        IsStaticPackage && \
            export LIB_TYPE="no-shared" || \
            export LIB_TYPE="shared"
        ConfigurePkgInBuildDir \
            --prefix="${PREFIX}/usr" \
            android \
            "${LIB_TYPE}" \
            no-capieng

        BuildPkg CALC_VERSIONS="SHLIB_COMPAT=;SHLIB_SOVER=" all
        InstallPkg CALC_VERSIONS="SHLIB_COMPAT=;SHLIB_SOVER=" install_sw

        unset ANDROID_DEV LIB_TYPE

        if ! IsStaticPackage
        then
            cp -af "${BUILD_DIR}/${PKG_SUBDIR}"/lib*.so "${PREFIX}/usr/lib/"
            rm -f "${PREFIX}/usr/lib/libcrypto.a" \
                  "${PREFIX}/usr/lib/libssl.a"
        fi

        rm -f  "${PREFIX}/usr/bin/openssl" \
               "${PREFIX}/usr/bin/c_rehash"
        rm -rf "${PREFIX}/usr/ssl/"

        UnsetCrossToolchainVariables
        CleanPkgBuildDir
        CleanPkgSrcDir
        CleanPrefixDir
    fi
)

