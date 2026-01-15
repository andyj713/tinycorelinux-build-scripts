#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}
BASE=${BASE:-/mnt/sda1/lamp}

EXT=xt_geoip_LE_IPv4

. $MEDIR/mkext-funcs.sh
set_vars
def_init

DEPS="xtables-addons-KERNEL tcl8.6 tcllib"

def_deps

mkdir -p $TCZ/usr/local/share/xt_geoip
rm -rf LE
mkdir LE

# IPv4
rm -rf GeoLite2-Country-CSV*
unzip -o -j $BASE/src/GeoLite2-Country-CSV_20*.zip

#tclsh /usr/local/libexec/xtables-addons/xt_geoip_build.tcl
tclsh $BASE/contrib/xt_geoip_build.tcl

cp -r LE $TCZ/usr/local/share/xt_geoip

set_perms
squash_tcz

