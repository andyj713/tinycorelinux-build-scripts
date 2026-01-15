#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=libzip

. $MEDIR/mkext-funcs.sh
set_vars
def_init

DEPS="cmake groff liblzma-dev"

def_deps
ccxx_opts lto noex

mkdir build
cd build
cmake .. -DCMAKE_INSTALL_LIBDIR=lib -DENABLE_GNUTLS=OFF

def_make
make_dev
def_move

mkdir -p $TCZ-bin/usr/local
mv $TCZ-dev/usr/local/bin $TCZ-bin/usr/local

def_strip
set_perms
squash_tcz

