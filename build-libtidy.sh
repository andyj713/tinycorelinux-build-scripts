#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=libtidy

. $MEDIR/mkext-funcs.sh
set_vars
def_init

DEPS="cmake libidn2-dev libxslt-dev"

test "$KBITS" = "64" || DEPS="$DEPS nettle"

def_deps
ccxx_opts lto noex

cmake . -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$TCZ-dev/usr/local"

def_make

make install || exit

def_move
def_strip
set_perms
squash_tcz

