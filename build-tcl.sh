#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=$1$2

. $MEDIR/mkext-funcs.sh
set_vars
def_init

DEPS="tzdata"

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
	--enable-dll-unloading \
	--without-tzdata \
	|| exit

def_make
make_inst

mkdir -p $TCZ/usr/local/lib/$EXT
cp -r ../library/*.tcl $TCZ/usr/local/lib/$EXT
for a in cookiejar dde encoding http msgcat msgs opt platform; do
	cp -r ../library/$a $TCZ/usr/local/lib/$EXT
done

chmod -R ug+w $TCZ

mkdir -p $TCZ-doc/usr/local
mv $TCZ/usr/local/man $TCZ-doc/usr/local
mv $TCZ/usr/local/share $TCZ-doc/usr/local

mkdir -p $TCZ-dev/usr/local/lib
mkdir -p $TCZ-dev/usr/local/bin
mv $TCZ/usr/local/include $TCZ-dev/usr/local
mv $TCZ/usr/local/lib/pkgconfig $TCZ-dev/usr/local/lib
mv $TCZ/usr/local/lib/tcl*.sh $TCZ-dev/usr/local/lib
mv $TCZ/usr/local/bin/sqlite3_analyzer $TCZ-dev/usr/local/bin
CURDIR=$(pwd); cd $TCZ/usr/local/bin; ln -s tclsh$2 tclsh; cd $CURDIR

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
