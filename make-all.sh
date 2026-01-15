#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

export NOLTO="$1"

. $MEDIR/mkext-funcs.sh
set_vars

sudo chown -R root.staff /usr/local/tce.installed
sudo chmod -R 775 /usr/local/tce.installed

## tier 1

# drop libmcrypt libmspack

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
	libevent libfastjson liblogging \
	libsodium libnet unixODBC
	do build_one $x
done

build_one nghttp2 libnghttp2
build_one onig libonig
build_one tidy-html5 libtidy
#build_one cyrus-sasl cyrus-sasl-lite
#test "$KBITS" == "64" && build_one tzdb tzdata
build_one tzdb tzdata
test "$KBITS" == "64" && build_one log4cplus 

TCLVER=8.6
TCLPATCH=$TCLVER.17

cd $BUILD
sudo rm -rf $BUILD/tcl$TCLPATCH
tar xf $SOURCE/tcl$TCLPATCH-src.tar.gz
cd $BUILD/tcl$TCLPATCH/unix
echo -e "\n=====  build-tcl$TCLVER.sh =====\n"
$PROD/build-tcl$TCLVER.sh
copy_tcz tcl$TCLVER


## tier 2


for x in bind dhcp tcllib libgd liblognorm openldap
	do build_one $x
done

for x in $(seq 12 18)
	do build_one postgresql postgresql "-$x" "$x"
done

TKVER=${TCLVER}
TKPATCH=${TCLPATCH}

cd $BUILD
sudo rm -rf $BUILD/tk$TKPATCH
tar xf $SOURCE/tk$TKPATCH-src.tar.gz
cd $BUILD/tk$TKPATCH/unix
echo -e "\n=====  build-tk$TKVER.sh =====\n"
$PROD/build-tk$TKVER.sh
copy_tcz tk$TKVER



cd $BUILD
sudo rm -rf $BUILD/tcludp
tar xf $SOURCE/tcludp-1.0.11.tar.gz
cd $BUILD/tcludp
echo -e "\n=====  build-tcludp.sh =====\n"
$PROD/build-tcludp.sh
copy_tcz tcludp


build_one tcltls


## tier 3


cd $BUILD
sudo rm -rf $BUILD/pgtcl2.1.1
tar xf $SOURCE/pgtcl2.1.1.tar.gz
cd $BUILD/pgtcl2.1.1
echo -e "\n=====  build-pgtclng.sh =====\n"
$PROD/build-pgtclng.sh
copy_tcz pgtclng 


#build_one cyrus-sasl


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

for x in 8.1 8.2 8.3 8.4 8.5
	do build_one php php "-$x" "$x"
done


## xapps

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


test "$KBITS" == 64 && build_one kea

build_one open-vm-tools

build_one libptytty

build_one rxvt-unicode rxvt

build_one iftop

build_one xtables-addons xtables-addons "-$(uname -r)"

cd $BUILD
sudo rm -rf $BUILD/LE
echo -e "\n=====  build-xt_geoip.sh =====\n"
$PROD/build-xt_geoip.sh
copy_tcz xt_geoip_LE_IPv4


build_one rsyslog


TCLVER=9.0
TCLPATCH=$TCLVER.3

cd $BUILD
sudo rm -rf $BUILD/tcl$TCLPATCH
tar xf $SOURCE/tcl$TCLPATCH-src.tar.gz
cd $BUILD/tcl$TCLPATCH/unix
echo -e "\n=====  build-tcl$TCLVER.sh =====\n"
$PROD/build-tcl$TCLVER.sh
copy_tcz tcl$TCLVER


TKVER=${TCLVER}
TKPATCH=${TCLPATCH}

cd $BUILD
sudo rm -rf $BUILD/tk$TKPATCH
tar xf $SOURCE/tk$TKPATCH-src.tar.gz
cd $BUILD/tk$TKPATCH/unix
echo -e "\n=====  build-tk$TKVER.sh =====\n"
$PROD/build-tk$TKVER.sh
copy_tcz tk$TKVER


