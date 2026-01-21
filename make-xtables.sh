#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

export NOLTO="$1"

. $MEDIR/mkext-funcs.sh
set_vars

sudo chown -R root:staff /usr/local/tce.installed
sudo chmod -R 775 /usr/local/tce.installed

build_one iftop

build_one xtables-addons xtables-addons "-$(uname -r)"

cd $BUILD
sudo rm -rf $BUILD/LE
echo -e "\n=====  build-xt_geoip.sh =====\n"
$PROD/build-xt_geoip.sh
copy_tcz xt_geoip_LE_IPv4

