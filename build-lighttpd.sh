#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=lighttpd

. $MEDIR/mkext-funcs.sh
set_vars
def_init

case $TCVER in
        64-17 ) PCREVER=21042 ;;
        32-17 ) PCREVER=21042 ;;
        64-16 ) PCREVER=21042 ;;
        32-16 ) PCREVER=21042 ;;
        64-15 ) PCREVER=21042 ;;
        32-15 ) PCREVER=21042 ;;
        64-14 ) PCREVER=21042 ;;
        32-14 ) PCREVER=21042 ;;
        64-13 ) PCREVER=21032 ;;
        32-13 ) PCREVER=2 ;;
esac

DEPS="$DBDEPS gdbm-dev cyrus-sasl-dev
	attr-dev openldap-dev libxml2-dev sqlite3-dev
	autoconf automake autogen pcre$PCREVER-dev"

./autogen.sh

def_deps
ccxx_opts lto noex

./configure \
	--libdir=/usr/local/lib/lighttpd \
	--sysconfdir=/usr/local/etc/lighttpd \
	--localstatedir=/var \
	--enable-shared \
	--with-openssl \
	--with-pcre2 \
	--with-zlib \
	--with-zstd \
	--with-bzip2 \
	--with-mysql=/usr/local/mysql/bin/mysql_config \
	--with-pgsql=/usr/local/pgsql$PGVER/bin/pg_config \
	--with-sasl \
	--with-ldap \
	--with-attr \
	--with-webdav-props \
	--with-webdav-locks \
	--with-libxml \
	--with-sqlite \
	--with-uuid \
	|| exit

def_make
make_inst
def_strip
set_perms
squash_tcz

