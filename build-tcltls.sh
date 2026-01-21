#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=tcltls

. $MEDIR/mkext-funcs.sh
set_vars
def_init

DEPS="tcl8.6 tcl8.6-dev openssl$SSLVER-dev"

def_deps
ccxx_opts lto noex
def_conf
def_make
make_inst

#chmod -R ug+w $TCZ

def_strip
set_perms
squash_tcz

