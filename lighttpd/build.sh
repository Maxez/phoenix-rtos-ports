#!/bin/bash
LIGHTTPD="lighttpd-1.4.50"

b_log "Building lighttpd"


PREFIX_LIGHTTPD=${TOPDIR}/phoenix-rtos-ports/lighttpd
PREFIX_LIGHTTPD_BUILD=${PREFIX_BUILD}/lighttpd
PREFIX_LIGHTTPD_SRC=${PREFIX_LIGHTTPD}/${LIGHTTPD}
PREFIX_PCRE_BUILD=${PREFIX_BUILD}/pcre

#
# Download and unpack
#
mkdir -p "$PREFIX_LIGHTTPD_BUILD"

if [ ! -z "$CLEAN" ]; then
        [ -f "$PREFIX_LIGHTTPD/${LIGHTTPD}.tar.gz" ] || wget https://download.lighttpd.net/lighttpd/releases-1.4.x/${LIGHTTPD}.tar.gz -P "$PREFIX_LIGHTTPD" --no-check-certificate
        if [ ! -d "$PREFIX_LIGHTTPD_SRC" ];then
		tar zxf "$PREFIX_LIGHTTPD/${LIGHTTPD}.tar.gz" -C "$PREFIX_LIGHTTPD"

		for patchfile in ${PREFIX_LIGHTTPD}/patches/*.patch; do
			echo "applying patch: $patchfile"
        		patch -d $PREFIX_LIGHTTPD_SRC -p1 -p1 < $patchfile 
		done
	fi

 cat $PREFIX_FS/root/etc/lighttpd.conf | grep mod_ | cut -d'"' -f2 | xargs -L1 -I{} echo "PLUGIN_INIT({})" > $PREFIX_LIGHTTPD_SRC/src/plugin-static.h

        [ -f "$PREFIX_LIGHTTPD_SRC/config.cache" ] && rm $PREFIX_LIGHTTPD_SRC/config.cache
        
	LIGHTTPD_CFLAGS="-I$PREFIX_PCRE_BUILD -DLIGHTTPD_STATIC -DPHOENIX"

        LIGHTTPD_LDFLAGS="-L$PREFIX_PCRE_BUILD"

#
# Configure
#

      ( cd $PREFIX_LIGHTTPD_BUILD && $PREFIX_LIGHTTPD_SRC/configure LIGHTTPD_STATIC=yes CFLAGS="${LIGHTTPD_CFLAGS} ${CFLAGS}" LDFLAGS="${LIGHTTPD_LDFLAGS} ${LDFLAGS}" AR_FLAGS="-r" -C --disable-ipv6 --disable-mmap --with-bzip2=no \
                --with-zlib=no --enable-shared=no --enable-static=yes --disable-shared --host="$TARGET_FAMILY" -target="$TARGET_FAMILY" CC=${CROSS}gcc \
                AR=${CROSS}ar LD=${CROSS}ld AS=${CROSS}as --prefix="$PREFIX_FS/root" ) 


        sed -i 's/#define HAVE_MMAP 1//g' $PREFIX_LIGHTTPD_BUILD/config.h
        sed -i 's/#define HAVE_MUNMAP 1//g' $PREFIX_LIGHTTPD_BUILD/config.h
        sed -i 's/#define HAVE_GETRLIMIT 1//g' $PREFIX_LIGHTTPD_BUILD/config.h
        sed -i 's/#define HAVE_SYS_POLL_H 1//g' $PREFIX_LIGHTTPD_BUILD/config.h
        sed -i 's/#define HAVE_SIGACTION 1//g' $PREFIX_LIGHTTPD_BUILD/config.h
        sed -i 's/#define HAVE_DLFCN_H 1//g' $PREFIX_LIGHTTPD_BUILD/config.h

fi

#
# Make
#
#cd ${PREFIX_LIGHTTPD_BUILD}
#echo ${MAKEFLAGS}
make -C ${PREFIX_LIGHTTPD_BUILD} -f ${PREFIX_LIGHTTPD_BUILD}/Makefile  CROSS_COMPILE="$CROSS"  ${MAKEFLAGS} install

${CROSS}strip -s $PREFIX_FS/root/sbin/lighttpd -o $PREFIX_PROG_STRIPPED/lighttpd
b_install "$PREFIX_PROG_STRIPPED/lighttpd" /sbin

