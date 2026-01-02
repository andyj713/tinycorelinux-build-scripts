#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=cyrus-sasl-lite

. $MEDIR/phase-default-vars.sh
. $MEDIR/phase-default-init.sh

DEPS="$DBDEPS libtool-dev autoconf automake gdbm-dev groff"

for a in $(find $SOURCE/$EXT-patches -name "*.patch-$RVER"); do
        echo "applying patch file $a"
        patch -N -p 0 < $a       
done           

. $MEDIR/phase-default-deps.sh
. $MEDIR/phase-cc-opts-no-flto.sh

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

. $MEDIR/phase-default-make.sh
. $MEDIR/phase-make-install-dev.sh

mkdir -p $TCZ/usr/local/etc/sasl2/db
mkdir -p $TCZ/usr/local/lib/sasl2

mv $TCZ-dev/usr/local/sbin $TCZ/usr/local
mv $TCZ-dev/usr/local/lib/*.so* $TCZ/usr/local/lib
mv $TCZ-dev/usr/local/lib/sasl2/*.so* $TCZ/usr/local/lib/sasl2

. $MEDIR/phase-default-strip.sh
. $MEDIR/phase-default-set-perms.sh
. $MEDIR/phase-default-squash-tcz.sh

