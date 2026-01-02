#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=libtidy

. $MEDIR/phase-default-vars.sh
. $MEDIR/phase-default-init.sh

DEPS="cmake libidn2-dev libxslt-dev"

test "$KBITS" = "64" || DEPS="$DEPS nettle"

. $MEDIR/phase-default-deps.sh
. $MEDIR/phase-default-cc-opts.sh

cmake . -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$TCZ-dev/usr/local"

. $MEDIR/phase-default-make.sh

make install || exit

. $MEDIR/phase-default-move-dev.sh
. $MEDIR/phase-default-strip.sh
. $MEDIR/phase-default-set-perms.sh
. $MEDIR/phase-default-squash-tcz.sh

