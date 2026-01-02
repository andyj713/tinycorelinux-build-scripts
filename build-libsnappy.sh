#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=libsnappy

. $MEDIR/phase-default-vars.sh
. $MEDIR/phase-default-init.sh

DEPS="cmake xz lzo-dev"

. $MEDIR/phase-default-deps.sh
. $MEDIR/phase-default-cc-opts.sh

#mkdir build
#cd build
#cmake .. -DSNAPPY_BUILD_TESTS=off -DSNAPPY_BUILD_BENCHMARKS=off

./configure

. $MEDIR/phase-default-make.sh
. $MEDIR/phase-make-install-dev.sh
. $MEDIR/phase-default-move-dev.sh

mv $TCZ-dev/usr/local/lib/libsnappy.a $TCZ/usr/local/lib

. $MEDIR/phase-default-strip.sh
. $MEDIR/phase-default-set-perms.sh
. $MEDIR/phase-default-squash-tcz.sh

