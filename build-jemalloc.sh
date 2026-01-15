#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=jemalloc

. $MEDIR/mkext-funcs.sh
set_vars
def_init

DEPS="libtool-dev autoconf automake"

def_deps
ccxx_opts lto ""

autoconf
./configure \
	--prefix=/usr/local \
	--localstatedir=/var \
	--sysconfdir=/usr/local/etc \
	--disable-static \
	--enable-autogen \
	|| exit

def_make
make_dev
def_move
def_strip
set_perms
squash_tcz

