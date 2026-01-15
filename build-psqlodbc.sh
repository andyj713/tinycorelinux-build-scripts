#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=psqlodbc

. $MEDIR/mkext-funcs.sh
set_vars
def_init

DEPS="postgresql-18-dev postgresql-18 unixODBC-dev unixODBC"

def_deps
ccxx_opts lto noex

./configure \
	--with-unixodbc \
	--with-libpq=/usr/local/pgsql15 \
	|| exit

def_make
make_inst
def_strip
set_perms
squash_tcz

