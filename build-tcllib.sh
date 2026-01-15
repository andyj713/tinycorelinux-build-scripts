#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=$1

. $MEDIR/mkext-funcs.sh
set_vars
def_init

DEPS="tcl8.6 tcl8.6-dev"

def_deps
ccxx_opts lto noex
def_conf
make_inst

make install DESTDIR=$TCZ

mkdir -p $TCZ-doc/usr/local
mv $TCZ/usr/local/man $TCZ-doc/usr/local

def_strip
set_perms
squash_tcz

