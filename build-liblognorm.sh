#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=liblognorm

. $MEDIR/mkext-funcs.sh
set_vars
def_init

#DEPS="libestr-dev libfastjson-dev pcre21042-dev"
DEPS="libestr-dev libfastjson-dev pcre-dev"

def_deps
ccxx_opts lto noex

autoreconf -i
./configure \
	--enable-shared \
	--enable-regexp \
	|| exit

def_make
make_dev

mkdir -p $TCZ/usr/local/lib
mv $TCZ-dev/usr/local/lib/*.so* $TCZ/usr/local/lib
mv $TCZ-dev/usr/local/bin $TCZ/usr/local

def_strip
set_perms
squash_tcz

