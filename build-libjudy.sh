#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=libjudy

. $MEDIR/mkext-funcs.sh
set_vars
def_init

DEPS=""

def_deps
ccxx_opts lto noex

#	--enable-64-bit \

./configure \
	--enable-shared \
	--disable-static \
	|| exit

def_make
make_inst

mkdir -p $TCZ-doc/usr/local
mv $TCZ/usr/local/share $TCZ-doc/usr/local

mkdir -p $TCZ-dev/usr/local
mv $TCZ/usr/local/include $TCZ-dev/usr/local

def_strip
set_perms
squash_tcz

