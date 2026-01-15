#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=libnghttp2

. $MEDIR/mkext-funcs.sh
set_vars
def_init

DEPS=""

def_deps
ccxx_opts lto noex

make clean
./configure \
	--enable-lib-only \
	--disable-python-bindings \
	|| exit

def_make
make_dev

mkdir -p $TCZ/usr/local/libexec
mkdir -p $TCZ/usr/local/lib
mv $TCZ-dev/usr/local/share/nghttp2 $TCZ/usr/local/libexec
mv $TCZ-dev/usr/local/lib/*.so* $TCZ/usr/local/lib

def_strip
set_perms
squash_tcz

