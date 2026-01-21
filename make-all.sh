#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

export NOLTO="$1"

. $MEDIR/mkext-funcs.sh
set_vars

sudo chown -R root:staff /usr/local/tce.installed
sudo chmod -R 775 /usr/local/tce.installed

## tier 1

#test "$KBITS" == "64" && build_one tzdb tzdata
build_one tzdb tzdata

LIBAIOVER=0.3.113
LIBAIODEB=2

cd $BUILD
sudo rm -rf $BUILD/libaio-$LIBAIOVER
tar xf $SOURCE/libaio_$LIBAIOVER.orig.tar.gz
cd $BUILD/libaio-$LIBAIOVER
tar xf $SOURCE/libaio_$LIBAIOVER-$LIBAIODEB.debian.tar.xz
echo -e "\n=====  build-libaio.sh =====\n"
$PROD/build-libaio.sh
copy_tcz libaio

for x in apr jemalloc libdnet libestr libzip \
	libfastjson liblogging libsodium libnet \
	unixODBC liblognorm libgd
	do build_one $x
done

build_one nghttp2 libnghttp2
build_one onig libonig
build_one tidy-html5 libtidy
build_one cyrus-sasl cyrus-sasl "-lite"
test "$KBITS" == "64" && build_one log4cplus 


## tier 2

build_one openldap libevent

for x in $(seq 12 18)
	do build_one postgresql postgresql "-$x" "$x"
done


## tier 3


cd $BUILD
sudo rm -rf $BUILD/pgtcl2.1.1
tar xf $SOURCE/pgtcl2.1.1.tar.gz
cd $BUILD/pgtcl2.1.1
echo -e "\n=====  build-pgtclng.sh =====\n"
$PROD/build-pgtclng.sh
copy_tcz pgtclng 


build_one cyrus-sasl


## tier 4


for x in apr-util net-snmp
	do build_one $x
done

## tier 5


build_one httpd apache "2.4"

for x in nginx lighttpd
	do build_one $x
done


# tier 6

for x in $(seq 1 5)
	do build_one php php "-8.$x" "8.$x"
done


## xapps and requiring python

build_one bind
build_one dhcp


# gvim

cd $BUILD

SRC=$(basename $(find $SOURCE -regex ".*/vim[\.-].*" | sort | head -1))
STYPE=${SRC##*.}
SVER=${SRC#vim*}
SVER=${SVER%.tar*}
echo SRC="$SRC"
echo STYPE="$STYPE"
echo SVER="$SVER"
sudo rm -rf vim$SVER gvim$SVER
tar xf $SOURCE/$SRC
mv vim$SVER gvim$SVER
tar xf $SOURCE/$SRC
echo -e "\n=====  build-gvim.sh =====\n"
$PROD/build-gvim.sh $SVER
copy_tcz gvim


#test "$KBITS" == 64 && build_one kea

build_one open-vm-tools

build_one rsyslog

