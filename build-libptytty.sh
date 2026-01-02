#!/bin/sh -v
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=rxvt

. $MEDIR/phase-default-vars.sh
. $MEDIR/phase-default-init.sh

DEPS="cmake"

. $MEDIR/phase-default-deps.sh
. $MEDIR/phase-cc-opts-flto.sh

export LDFLAGS="-lstdc++"

. $MEDIR/phase-default-cmake.sh
. $MEDIR/phase-make-install-dev.sh

sudo make install

cd ..

. $MEDIR/phase-default-move-dev.sh
. $MEDIR/phase-default-strip.sh

