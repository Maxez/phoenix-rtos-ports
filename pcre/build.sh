#!/bin/bash
PCRE=pcre-8.42

b_log "Building pcre"
PREFIX_PCRE=${TOPDIR}/phoenix-rtos-ports/pcre
PREFIX_PCRE_BUILD=${PREFIX_BUILD}/pcre
PREFIX_PCRE_SRC=${PREFIX_PCRE}/${PCRE}

#
# Download and unpack
#
mkdir -p "$PREFIX_PCRE_BUILD"

if [ ! -z "$CLEAN" ]; then

	rm -fr $PREFIX_PCRE_BUILD/*

	[ -f "$PREFIX_PCRE/${PCRE}.tar.bz2" ] || wget http://ftp.pcre.org/pub/pcre/${PCRE}.tar.bz2 -P "$PREFIX_PCRE"
	[ -d "$PREFIX_PCRE_SRC" ] || tar jxf "$PREFIX_PCRE/${PCRE}.tar.bz2" -C "$PREFIX_PCRE"

	PCRE_CFLAGS=""
	PCRE_LDFLAGS=""

#
# Configure
#
	( cd ${PREFIX_PCRE_BUILD} && ${PREFIX_PCRE_SRC}/configure CFLAGS="${PCRE_CFLAGS} ${CFLAGS}" LDFLAGS="${PCRE_LDFLAGS} ${LDFLAGS}" ARFLAGS="-r" --enable-static --disable-shared --host="$TARGET_FAMILY" --target="$TARGET_FAMILY" \
                --disable-cpp CC=${CROSS}gcc AR=${CROSS}ar LD=${CROSS}ld AS=${CROSS}as RANLIB=${CROSS}gcc-ranlib --prefix="${PREFIX_FS}/root")
#                --libdir="${PREFIX_PCRE_BUILD}/user-lib" \
#                --includedir="${PREFIX_PCRE_BUILD}/user-include" )
fi

#
# Make
#
make -C "$PREFIX_PCRE_BUILD" CROSS_COMPILE="$CROSS" ${MAKEFLAGS} ${CLEAN} install