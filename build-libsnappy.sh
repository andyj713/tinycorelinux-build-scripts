#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=libsnappy

. $MEDIR/mkext-funcs.sh
set_vars
def_init

DEPS="cmake xz lzo-dev"

def_deps
ccxx_opts lto noex

#mkdir build
#cd build
#cmake .. -DSNAPPY_BUILD_TESTS=off -DSNAPPY_BUILD_BENCHMARKS=off

./configure

def_make
make_dev
def_move

mv $TCZ-dev/usr/local/lib/libsnappy.a $TCZ/usr/local/lib

def_strip
set_perms
squash_tcz

