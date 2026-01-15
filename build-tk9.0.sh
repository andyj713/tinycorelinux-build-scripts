#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=tk9.0

. $MEDIR/mkext-funcs.sh
set_vars
def_init

DEPS="tcl9.0 tcl9.0-dev xorg-proto Xorg-7.7-dev"

def_deps
ccxx_opts lto noex

export LDFLAGS="-lm"

./configure \
	--prefix=/usr/local \
	--localstatedir=/var \
	--disable-rpath \
	--enable-64bit \
	--enable-shared \
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

mkdir -p $TCZ-dev/usr/local/lib/tk9.0
mv $TCZ/usr/local/include $TCZ-dev/usr/local
mv $TCZ/usr/local/lib/tk9.0/demos $TCZ-dev/usr/local/lib/tk9.0
mv $TCZ/usr/local/lib/pkgconfig $TCZ-dev/usr/local/lib
mv $TCZ/usr/local/lib/tk*.sh $TCZ-dev/usr/local/lib
CURDIR=$(pwd); cd $TCZ/usr/local/bin; ln -s wish9.0 wish; cd $CURDIR

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

