#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=pgtclng

. $MEDIR/mkext-funcs.sh
set_vars
def_init

DEPS="$DBDEPS tcl8.6-dev"

def_deps
ccxx_opts lto noex

./configure \
	--with-tcl=/usr/local/lib \
	--with-tclinclude=/usr/local/include \
	--with-postgres-include=/usr/local/pgsql$PGVER/include \
	--with-postgres-lib=/usr/local/pgsql$PGVER/lib \
	|| exit

def_make
make_inst
def_strip
set_perms
squash_tcz

