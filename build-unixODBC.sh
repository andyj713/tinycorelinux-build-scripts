#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=unixODBC

. $MEDIR/phase-default-vars.sh
. $MEDIR/phase-default-init.sh

DEPS="ncursesw-dev"

. $MEDIR/phase-default-deps.sh
. $MEDIR/phase-default-cc-opts.sh
. $MEDIR/phase-default-config.sh
. $MEDIR/phase-default-make.sh
. $MEDIR/phase-make-install-dev.sh

mkdir -p $TCZ/usr/local/lib
mv $TCZ-dev/usr/local/lib/*.so* $TCZ/usr/local/lib
mv $TCZ-dev/usr/local/etc $TCZ/usr/local
mv $TCZ-dev/usr/local/bin $TCZ/usr/local

mkdir -p $TCZ-dev/usr/local/bin
mv $TCZ/usr/local/bin/odbc_config $TCZ-dev/usr/local/bin

. $MEDIR/phase-default-strip.sh
. $MEDIR/phase-default-set-perms.sh

sudo rm $TCZ/usr/local/etc/odbc*.ini
sudo cp $BASE/contrib/odbc*-sample $TCZ/usr/local/etc

. $MEDIR/phase-default-squash-tcz.sh

