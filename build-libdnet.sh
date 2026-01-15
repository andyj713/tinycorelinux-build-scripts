#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=libdnet

. $MEDIR/mkext-funcs.sh
set_vars
def_init

DEPS="libtool-dev autoconf automake"

def_deps
ccxx_opts "" noex

export LDFLAGS="-lm"

#sh ./autogen.sh

./configure \
	--disable-check \
	|| exit

def_make
make_dev
def_move

mv $TCZ-dev/usr/local/sbin $TCZ/usr/local
mkdir -p $TCZ-dev/usr/local/share
mv $TCZ-dev/usr/local/man $TCZ-dev/usr/local/share

def_strip
set_perms
squash_tcz

