#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=apr-util

. $MEDIR/mkext-funcs.sh
set_vars
def_init

DEPS="$DBDEPS apr-dev openldap-dev gdbm-dev oracle-12.2-client libtool-dev expat2-dev sqlite3-dev unixODBC-dev"

def_deps
ccxx_opts lto noex

sed -i -e 's/lnnz11/lnnz12/g' configure
sed -i -e 's/lnnz10/lnnz/g' configure

#./buildconf --with-apr=$BUILD/apr-1.6.5

make clean

export CPPFLAGS="-D_FILE_OFFSET_BITS=64"

CONFHEAD="./configure 
	--prefix=/usr/local 
	--localstatedir=/var 
	--with-apr=/usr/local 
	--with-crypto 
	--with-openssl 
	--with-expat=/usr/local 
	--with-gdbm 
	--with-dbm=gdbm 
	--without-berkeley-db "

$CONFHEAD \
	--with-oracle=/usr/local/oracle \
	--with-oracle-include=/usr/local/oracle/sdk/include \
	|| exit

mv config.log config-ora.log

def_make

make install DESTDIR=$TCZ-ora

make clean

$CONFHEAD \
	--with-pgsql=/usr/local/pgsql$PGVER \
	--with-mysql=/usr/local/mysql \
	--with-sqlite3=/usr/local \
	--with-odbc=/usr/local \
	--with-ldap \
	|| exit

#sed -i -e '/^INCLUDES =/s#/usr/local/include#/usr/local/mysql/include#' Makefile
#sed -i -e '/^APU_MODULES =/s#$# dbd/apr_dbd_mysql.la#' Makefile
#sed -i -e '/^LDADD_dbd_mysql =/s#$# -L/usr/local/mysql/lib -lmariadb#' Makefile

def_make
make_dev

mkdir -p $TCZ/usr/local/lib/apr-util-1

mv $TCZ-dev/usr/local/lib/*.so* $TCZ/usr/local/lib
mv $TCZ-dev/usr/local/lib/apr-util-1/*.so* $TCZ/usr/local/lib/apr-util-1
mv $TCZ-ora/usr/local/lib/apr-util-1/*oracle*.so* $TCZ/usr/local/lib/apr-util-1
mv $TCZ-ora/usr/local/lib/apr-util-1/*oracle* $TCZ-dev/usr/local/lib/apr-util-1

sed -i -e 's/APU_HAVE_ORACLE.*$/APU_HAVE_ORACLE\t11/' $TCZ-dev/usr/local/include/apr-1/apu.h

rm -rf $TCZ-ora/

def_strip
set_perms
squash_tcz

