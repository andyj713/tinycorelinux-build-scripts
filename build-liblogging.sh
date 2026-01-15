#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=liblogging

. $MEDIR/mkext-funcs.sh
set_vars
def_init

DEPS=""

def_deps
ccxx_opts lto noex

./configure \
	--prefix=/usr/local \
	--localstatedir=/var \
	--enable-shared \
	--enable-stdlog \
	--disable-journal \
	|| exit

def_make
make_dev

mkdir -p $TCZ/usr/local/lib
mv $TCZ-dev/usr/local/lib/*.so* $TCZ/usr/local/lib
mv $TCZ-dev/usr/local/bin $TCZ/usr/local

def_strip
set_perms
squash_tcz

