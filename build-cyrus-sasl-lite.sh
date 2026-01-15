#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=cyrus-sasl-lite

. $MEDIR/mkext-funcs.sh
set_vars
def_init

DEPS="$DBDEPS libtool-dev autoconf automake gdbm-dev groff"

for a in $(find $SOURCE/$EXT-patches -name "*.patch-$RVER"); do
        echo "applying patch file $a"
        patch -N -p 0 < $a       
done           

def_deps
ccxx_opts "" noex

#./autogen.sh \
./configure \
	--prefix=/usr/local \
	--localstatedir=/var \
	--sysconfdir=/usr/local/etc/sasl2/ \
	--with-plugindir=/usr/local/lib/sasl2/ \
	--with-configdir=/usr/local/etc/sasl2/ \
	--with-saslauthd=/var/run/saslauthd \
	--enable-shared \
	--disable-static \
	--with-openssl \
	--with-gdbm \
	--with-dblib=gdbm \
	--with-dbpath=/usr/local/etc/sasl2/db/ \
	--with-pam=no \
	|| exit

find . -name Makefile -type f -exec sed -i 's/-g -O2//g' {} \;

def_make
make_dev

mkdir -p $TCZ/usr/local/etc/sasl2/db
mkdir -p $TCZ/usr/local/lib/sasl2

mv $TCZ-dev/usr/local/sbin $TCZ/usr/local
mv $TCZ-dev/usr/local/lib/*.so* $TCZ/usr/local/lib
mv $TCZ-dev/usr/local/lib/sasl2/*.so* $TCZ/usr/local/lib/sasl2

def_strip
set_perms
squash_tcz

