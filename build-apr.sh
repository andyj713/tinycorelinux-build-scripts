#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=apr

. $MEDIR/mkext-funcs.sh
set_vars
def_init
def_deps
ccxx_opts lto noex

sed -i -e '/sizeof(off_t/s#!= 4#!= 8#' configure
sed -i -e '/4yes/s/4yes/8yes/' configure

export CPPFLAGS="-D_FILE_OFFSET_BITS=64"

./configure \
	--prefix=/usr/local \
	--localstatedir=/var \
	--enable-threads \
	--enable-posix-shm \
	|| exit

def_make
make_dev
def_move
def_strip
set_perms
squash_tcz

