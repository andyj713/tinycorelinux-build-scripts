#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=libnet

. $MEDIR/mkext-funcs.sh
set_vars
def_init

DEPS=""

def_deps
ccxx_opts lto noex
def_conf

sed -i -e '/^SUBDIRS/s/doc//' Makefile

def_make
make_dev
def_move
def_strip
set_perms
squash_tcz

