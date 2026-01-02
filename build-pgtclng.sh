#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=pgtclng

. $MEDIR/phase-default-vars.sh
. $MEDIR/phase-default-init.sh

DEPS="$DBDEPS tcl8.6-dev"

. $MEDIR/phase-default-deps.sh
. $MEDIR/phase-default-cc-opts.sh

./configure \
	--with-tcl=/usr/local/lib \
	--with-tclinclude=/usr/local/include \
	--with-postgres-include=/usr/local/pgsql$PGVER/include \
	--with-postgres-lib=/usr/local/pgsql$PGVER/lib \
	|| exit

. $MEDIR/phase-default-make.sh
. $MEDIR/phase-default-make-install.sh
. $MEDIR/phase-default-strip.sh
. $MEDIR/phase-default-set-perms.sh
. $MEDIR/phase-default-squash-tcz.sh

