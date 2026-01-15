#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

. $MEDIR/mkext-funcs.sh
set_vars

build_one $1 $2 $3 $4

