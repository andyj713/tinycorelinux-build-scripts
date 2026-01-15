#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

KVER=$(uname -r)
EXT=xtables-addons-$KVER

. $MEDIR/mkext-funcs.sh
set_vars
def_init

case $TCVER in
	64-10 ) XDEPS="netfilter-KERNEL" ;;
	32-10 ) XDEPS="netfilter-KERNEL" ;;
	* ) XDEPS="ipv6-netfilter-KERNEL"
esac

DEPS="$XDEPS bash bc tcl8.6 glibc_apps iptables-dev"

def_deps
ccxx_opts lto noex

#sudo ln -sf $BASE$KBITS/kernel/linux-$KVER /lib/modules/$(uname -r)/build
#[ -e /etc/sysconfig/tcedir/copy2fs.flg ] && \
#        sudo ln -sf /usr /lib/modules/$(uname -r)/build || \
#        sudo ln -sf /tmp/tcloop/linux-4.19_api_headers/usr /lib/modules/$(uname -r)/build

./autogen.sh

for a in $(grep -r -l /usr/share/xt_geoip *); do sed -i -e 's#/usr/share/xt_geoip#/usr/local/share/xt_geoip/LE#g' $a; done

./configure \
	--prefix=/usr/local \
	--localstatedir=/var \
	--sysconfdir=/usr/local/etc \
	--with-kbuild=$LAMP/kernel/linux-${KVER%-*} \
	|| exit

bash -c make || exit

make_inst

gzip $TCZ/lib/modules/$KVER/updates/*.ko
mkdir -p $TCZ/usr/local/lib/modules/$KVER/kernel
mv $TCZ/lib/modules/$KVER/updates $TCZ/usr/local/lib/modules/$KVER/kernel
rm -rf $TCZ/lib

strip --strip-unneeded $TCZ/usr/local/lib/xtables/*
strip --strip-unneeded $TCZ/usr/local/lib/*.so*
strip --strip-unneeded $TCZ/usr/local/sbin/*

cp $BASE/contrib/xt_geoip_build.tcl $TCZ/usr/local/libexec/xtables-addons

set_perms
squash_tcz

