#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=lighttpd

. $MEDIR/phase-default-vars.sh
. $MEDIR/phase-default-init.sh

case $TCVER in
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

. $MEDIR/phase-default-deps.sh
. $MEDIR/phase-default-cc-opts.sh

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

. $MEDIR/phase-default-make.sh
. $MEDIR/phase-default-make-install.sh
. $MEDIR/phase-default-strip.sh
. $MEDIR/phase-default-set-perms.sh
. $MEDIR/phase-default-squash-tcz.sh

