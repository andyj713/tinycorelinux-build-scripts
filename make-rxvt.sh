#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

export NOLTO="$1"

. $MEDIR/mkext-funcs.sh
set_vars

sudo chown -R root:staff /usr/local/tce.installed
sudo chmod -R 775 /usr/local/tce.installed

build_one libptytty

build_one rxvt-unicode rxvt

