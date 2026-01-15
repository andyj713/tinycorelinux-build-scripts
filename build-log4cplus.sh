#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=log4cplus

. $MEDIR/mkext-funcs.sh
set_vars
def_init
def_deps
ccxx_opts lto ""

export CXXFLAGS="$CXXFLAGS -fexceptions"

./configure \
	--enable-lto \
	--with-iconv \
	--with-wchar_t-support \
	|| exit

def_make
make_dev
def_move
def_strip
set_perms
squash_tcz

