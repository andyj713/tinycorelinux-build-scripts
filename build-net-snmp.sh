#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=net-snmp

. $MEDIR/mkext-funcs.sh
set_vars
def_init

DEPS="$DBDEPS libtool-dev cmake readline-dev liblzma-dev perl5 
 libpcap-dev libpci-dev ncursesw-dev ncursesw-terminfo
 pcre-dev"
# perl5 libxml2-python glib2-python python3.9-dev python3.9-setuptools

def_deps
ccxx_opts lto noex

echo $PATH | grep -q mysql || export PATH=$PATH:/usr/local/mysql/bin

#sudo ln -s $(which python3) /usr/local/bin/python
#	--with-python-modules \
#	--with-perl-modules \
#	--with-mysql \
#	--without-kmem-usage \

#export CFLAGS="$CFLAGS -DHAVE_MYSQL_INIT=1 -DHAVE_MARIADB_LOAD_DEFAULTS=1"
export MAKEFLAGS=""

./configure \
	--prefix=/usr/local \
	--localstatedir=/var \
	--disable-embedded-perl \
	--with-openssl=/usr/local \
	--with-defaults \
	--without-rpm \
	--with-install-prefix=$TCZ \
	|| exit

sed -i -e "/PYMAKE) install/s#basedir#root=$TCZ --basedir#" Makefile

# configure option --without-kmem-usage is broken
#sed -i -e '/define HAVE_KMEM/s%#define HAVE_KMEM "/dev/kmem"%/* #undef HAVE_KMEM */%' include/net-snmp/net-snmp-config.h

def_make
make_inst

chmod -R ug+w $TCZ

mkdir -p $TCZ-dev/usr/local/bin
mkdir -p $TCZ-dev/usr/local/lib
mkdir -p $TCZ-dev/usr/local/share

mv $TCZ/usr/local/include $TCZ-dev/usr/local
mv $TCZ/usr/local/lib/*.a $TCZ-dev/usr/local/lib
mv $TCZ/usr/local/lib/*.la $TCZ-dev/usr/local/lib
#rm $TCZ/usr/local/lib/*.a
#rm $TCZ/usr/local/lib/*.la
mv $TCZ/usr/local/share/man $TCZ-dev/usr/local/share
mv $TCZ/usr/local/bin/net-snmp-config $TCZ-dev/usr/local/bin/net-snmp-config

def_strip
set_perms
squash_tcz

