#!/bin/sh

(
    PKG=openssl
    PKG_VERSION=1.0.2n
    PKG_CHECKSUM=370babb75f278c39e0c50e8c4e7493bc0f18db6867478341a832a982fd15a8fe
    PKG_SUBDIR=${PKG}-${PKG_VERSION}
    PKG_FILE=${PKG}-${PKG_VERSION}.tar.gz
    PKG_URL="ftp://ftp.openssl.org/source/${PKG_FILE}"
    PKG_URL_2="ftp://ftp.openssl.org/source/old/${OPENSSL_SUBVER}/${PKG_FILE}"
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
        export ANDROID_DEV="${ANDROID_SYSROOT}/usr"
        export HOSTCC=gcc
        unset cc CC cpp CPP cxx CXX
        unset AR AS LD NM OBJCOPY OBJDUMP RANLIB STRIP
        ConfigurePkgInBuildDir \
            --prefix="${SYSROOT}/usr" \
            android \
            shared \
            no-capieng

        #BuildPkg CALC_VERSIONS="SHLIB_COMPAT=;SHLIB_SOVER=" depend
        BuildPkg CALC_VERSIONS="SHLIB_COMPAT=;SHLIB_SOVER=" all
        InstallPkg CALC_VERSIONS="SHLIB_COMPAT=;SHLIB_SOVER=" install_sw

        unset ANDROID_DEV HOSTCC

        cp -af "${BUILD_DIR}/${PKG_SUBDIR}"/lib*.so "${SYSROOT}/usr/lib/"
        rm -rf "${SYSROOT}/usr/ssl/"

        UnsetCrossToolchainVariables
        CleanPkgBuildDir
        CleanPkgSrcDir
    fi
)

