#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=tcludp

. $MEDIR/mkext-funcs.sh
set_vars
def_init

DEPS="tcl8.6 tcl8.6-dev"

def_deps
ccxx_opts lto noex

export LDFLAGS="-lm"

./configure \
        --prefix=/usr/local \
        --localstatedir=/var \
        --disable-rpath \
        --enable-64bit \
        --enable-threads \
        --enable-shared \
        || exit

def_make
make_inst

chmod -R ug+w $TCZ

def_strip
set_perms
squash_tcz

