#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

. $MEDIR/phase-default-vars.sh
. $MEDIR/phase-make-funcs.sh

build_one $1 $2 $3 $4

