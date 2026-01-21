#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

TCLMAJ="$1"
export NOLTO="$2"

. $MEDIR/mkext-funcs.sh
set_vars

sudo chown -R root:staff /usr/local/tce.installed
sudo chmod -R 775 /usr/local/tce.installed

do_tcltk(){
	cd $BUILD
	sudo rm -rf $BUILD/$1$TCLPATCH
	tar xf $SOURCE/$1$TCLPATCH-src.tar.gz
	cd $BUILD/$1$TCLPATCH/unix
	echo -e "\n=====  build-$1$TCLVER.sh =====\n"
	$PROD/build-$1.sh $1 $TCLVER
	copy_tcz $1$TCLVER
}

if [ "$TCLMAJ" = "8" ]; then
	TCLVER=8.6
	TCLPATCH=$TCLVER.17
else
	TCLVER=9.0
	TCLPATCH=$TCLVER.3
fi

do_tcltk tcl

if [ "$TCLMAJ" = "8" ]; then
	build_one tcllib
	
	build_one tcltls
	
	cd $BUILD
	sudo rm -rf $BUILD/tcludp
	tar xf $SOURCE/tcludp-1.0.11.tar.gz
	cd $BUILD/tcludp
	echo -e "\n=====  build-tcludp.sh =====\n"
	$PROD/build-tcludp.sh
	copy_tcz tcludp
fi

do_tcltk tk

