#!/bin/sh 
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=rxvt

. $MEDIR/mkext-funcs.sh
set_vars
def_init

DEPS="cmake"

def_deps
ccxx_opts lto ""

export LDFLAGS="-lstdc++"

def_cmake
make_dev

sudo make install

cd ..

def_move
def_strip

