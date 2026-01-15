#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=unixODBC

. $MEDIR/mkext-funcs.sh
set_vars
def_init

DEPS="ncursesw-dev"

def_deps
ccxx_opts lto noex
def_conf
def_make
make_dev

mkdir -p $TCZ/usr/local/lib
mv $TCZ-dev/usr/local/lib/*.so* $TCZ/usr/local/lib
mv $TCZ-dev/usr/local/etc $TCZ/usr/local
mv $TCZ-dev/usr/local/bin $TCZ/usr/local

mkdir -p $TCZ-dev/usr/local/bin
mv $TCZ/usr/local/bin/odbc_config $TCZ-dev/usr/local/bin

def_strip
set_perms

sudo rm $TCZ/usr/local/etc/odbc*.ini
sudo cp $BASE/contrib/odbc*-sample $TCZ/usr/local/etc

squash_tcz

