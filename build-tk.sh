#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=$1$2

. $MEDIR/mkext-funcs.sh
set_vars
def_init

DEPS="tcl$2 tcl$2-dev xorg-proto Xorg-7.7-dev"

def_deps
ccxx_opts lto noex

export LDFLAGS="-lm"

./configure \
	--prefix=/usr/local \
	--sysconfdir=/usr/local/etc \
	--localstatedir=/var \
	--disable-rpath \
	--enable-shared \
	--disable-static \
	--enable-64bit \
	--enable-load \
	--with-x \
	--enable-xft \
	--enable-xss \
	--disable-zipfs \
	|| exit

def_make
make_inst

chmod -R ug+w $TCZ

mkdir -p $TCZ-doc/usr/local
mv $TCZ/usr/local/man $TCZ-doc/usr/local

mkdir -p $TCZ-dev/usr/local/lib/$EXT
mv $TCZ/usr/local/include $TCZ-dev/usr/local
mv $TCZ/usr/local/lib/$EXT/demos $TCZ-dev/usr/local/lib/$EXT
mv $TCZ/usr/local/lib/pkgconfig $TCZ-dev/usr/local/lib
mv $TCZ/usr/local/lib/tk*.sh $TCZ-dev/usr/local/lib
CURDIR=$(pwd); cd $TCZ/usr/local/bin; ln -s wish$2 wish; cd $CURDIR

for a in $(find $TCZ -name '*.a'); do
	b=$(echo $(dirname $a) | sed "s#$TCZ#$TCZ-dev#")
	mkdir -p $b
	mv $a $b
done
for a in $(find $TCZ -name '*.sh'); do
	b=$(echo $(dirname $a) | sed "s#$TCZ#$TCZ-dev#")
	mkdir -p $b
	mv $a $b
done

def_strip
set_perms
squash_tcz

