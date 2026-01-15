#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

. $MEDIR/mkext-funcs.sh
set_vars

sudo chown -R root.staff /usr/local/tce.installed
sudo chmod -R 775 /usr/local/tce.installed

#TCLVER=8.6
#TCLPATCH=$TCLVER.17

TCLVER=9.0
TCLPATCH=$TCLVER.2

cd $BUILD
sudo rm -rf $BUILD/tcl$TCLPATCH
tar xf $SOURCE/tcl$TCLPATCH-src.tar.gz
cd $BUILD/tcl$TCLPATCH/unix
echo -e "\n=====  build-tcl$TCLVER.sh =====\n"
$PROD/build-tcl$TCLVER.sh
copy_tcz tcl$TCLVER


for x in tcllib 
	do build_one $x
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



#cd $BUILD
#sudo rm -rf $BUILD/tcludp
#tar xf $SOURCE/tcludp-1.0.11.tar.gz
#cd $BUILD/tcludp
#echo -e "\n=====  build-tcludp.sh =====\n"
#$PROD/build-tcludp.sh
#copy_tcz tcludp


build_one tcltls


## tier 3


cd $BUILD
sudo rm -rf $BUILD/pgtcl2.1.1
tar xf $SOURCE/pgtcl2.1.1.tar.gz
cd $BUILD/pgtcl2.1.1
echo -e "\n=====  build-pgtclng.sh =====\n"
$PROD/build-pgtclng.sh
copy_tcz pgtclng 


