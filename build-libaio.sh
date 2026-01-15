#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=libaio

. $MEDIR/mkext-funcs.sh
set_vars
def_init

DEPS=""

def_deps
ccxx_opts "" noex

for a in $(cat debian/patches/series); do sed -n '/--- [^ ]*$/,$p' debian/patches/$a | patch -N -p1; done

sed -i -e '/^prefix/s#/usr#/usr/local#' src/Makefile
sed -i -e '/MK_CFLAGS=/s/-nostdlib //' src/Makefile

def_make
make_dev
def_move
def_strip
set_perms
squash_tcz

