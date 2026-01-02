#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=net-snmp

. $MEDIR/phase-default-vars.sh
. $MEDIR/phase-default-init.sh

DEPS="$DBDEPS libtool-dev cmake readline-dev liblzma-dev perl5 
 libpcap-dev libpci-dev ncursesw-dev ncursesw-terminfo
 pcre-dev"
# perl5 libxml2-python glib2-python python3.9-dev python3.9-setuptools

. $MEDIR/phase-default-deps.sh
. $MEDIR/phase-default-cc-opts.sh

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

. $MEDIR/phase-default-make.sh
. $MEDIR/phase-default-make-install.sh

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

. $MEDIR/phase-default-strip.sh
. $MEDIR/phase-default-set-perms.sh
. $MEDIR/phase-default-squash-tcz.sh

