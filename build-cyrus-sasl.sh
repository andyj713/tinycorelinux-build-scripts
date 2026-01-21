#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=$1$2

. $MEDIR/mkext-funcs.sh
set_vars
def_init

DEPS="openssl$SSLVER-dev libtool-dev autoconf automake gdbm-dev groff"

test -z "$2" && DEPS="$DEPS $DBDEPS sqlite3-dev openldap-dev"

for a in $(find -L $SOURCE/$EXT-patches -name "*.patch-$RVER"); do
        echo "applying patch file $a"
        patch -N -p 1 -i $a       
done           

def_deps
ccxx_opts lto noex

#export CFLAGS="$CFLAGS -std=gnu17"
#MAKEFLAGS=""

autoreconf -ivf

test -z "$2" && SASLFULL="--enable-sql \
	--with-mysql=/usr/local/mysql \
	--with-pgsql=/usr/local/pgsql$PGVER \
	--with-sqlite3=/usr/local \
	--with-ldap \
	--enable-ldapdb"
./configure \
	--prefix=/usr/local \
	--localstatedir=/var \
	--sysconfdir=/usr/local/etc/sasl2 \
	--with-plugindir=/usr/local/lib/sasl2 \
	--with-configdir=/usr/local/etc/sasl2 \
	--with-saslauthd=/var/run/saslauthd \
	--enable-shared \
	--disable-static \
	--with-devrandom=/dev/urandom \
	--with-openssl \
	--with-gdbm \
	--with-dblib=gdbm \
	--with-dbpath=/usr/local/etc/sasl2/db \
	--with-pam=no \
	--enable-obsolete_cram_attr=no \
	--enable-obsolete_digest_attr=no \
	--enable-cram=no \
	--enable-digest=no \
	$SASLFULL || exit

find . -name Makefile -type f -exec sed -i 's/-g -O2//g' {} \;
find . -name Makefile -type f -exec sed -i -e 's#/usr/local/mysql/include/mysql #/usr/local/mysql/include #' {} \;
find . -name Makefile -type f -exec sed -i -e 's#/usr/local/mysql #/usr/local/mysql/include #' {} \;

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

