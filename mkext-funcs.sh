#
#

set_vars(){
	test "$(uname -m)" = "x86_64" && KBITS=64 || KBITS=32
	tcver=$(version)
	TCVER=$KBITS-${tcver%.*}

	BASE=/mnt/sda1/lamp
	SOURCE=$BASE/src
	SCRIPTS=$BASE/scripts                           
	TCEOPT=/etc/sysconfig/tcedir/optional
                                         
	LAMP=/mnt/sdb1/lamp$TCVER
	BUILD=$LAMP/build
	STAGE=$LAMP/stage
	TCZTMP=$LAMP/tmp
	TCZ=$TCZTMP/$EXT/TCZ

	PROD="$SCRIPTS"                          

	case $TCVER in 
		32-10|32-11)
			PGVER=12
			SSLVER="1.1.1"
			MDBVER=10.4
			PYVER=3.6
			;;
		32-12)
			PGVER=13
			SSLVER="1.1.1"
			MDBVER=10.5
			PYVER=3.6
			;;
		32-13)
			PGVER=14
			SSLVER="1.1.1"
			MDBVER=10.6
			PYVER=3.6
			;;
		32-14)
			PGVER=15
			SSLVER=""
			MDBVER=11.2
			PYVER=3.6
			;;
		32-15)
			PGVER=16
			SSLVER=""
			MDBVER=11.2
			PYVER=3.9
			;;
		32-16)
			PGVER=18
			SSLVER=""
			MDBVER=12.1
			PYVER=3.9
			LZVER="lzip"
			MARCH=i486
			;;
		32-17)
			PGVER=18
			SSLVER=""
			MDBVER=12.1
			PYVER=3.9
			LZVER="lzip"
			MARCH=i486
			;;
		64-10|64-11)
			PGVER=12
			SSLVER="1.1.1"
			MDBVER=10.4
			PYVER=3.6
			LZVER="lzip"
			;;
		64-12)
			PGVER=13
			SSLVER="1.1.1"
			MDBVER=10.5
			PYVER=3.6
			LZVER="lzip"
			;;
		64-13)
			PGVER=14
			SSLVER="1.1.1"
			MDBVER=10.6
			PYVER=3.6
			LZVER="lzip"
			;;
		64-14)
			PGVER=15
			SSLVER=""
			MDBVER=11.2
			PYVER=3.6
			LZVER="lzip"
			;;
		64-15)
			PGVER=16
			SSLVER=""
			MDBVER=11.2
			PYVER=3.9
			LZVER="lzip"
			;;
		64-16)
			PGVER=18
			SSLVER=""
			MDBVER=12.1
			PYVER=3.9
			LZVER="lzip"
			;;
		64-17)
			PGVER=18
			SSLVER=""
			MDBVER=12.1
			PYVER=3.9
			LZVER="lzip"
			;;
	esac

	DBDEPS="openssl$SSLVER-dev postgresql-$PGVER-dev mariadb-$MDBVER-dev"

	#JOBS=$(grep -m 1 'cpu cores' /proc/cpuinfo | sed 's/^.*: *//')
	JOBS=$(nproc)
	export MAKEFLAGS="-j$JOBS"
}

def_init(){
	sudo rm -rf $TCZTMP/$EXT
	DEPS=""
}

def_deps(){
	DEPS="compiletc bash file squashfs-tools coreutils $DEPS python$PYVER-dev $LZVER"

	NOTFOUND=""
	for a in $DEPS; do
		tce-load -i $a || tce-load -iwl $a || NOTFOUND=x
	done
	test -z "$NOTFOUND" || exit
}

ccxx_opts(){
	test "$KBITS" = 32 && CCXX="-march=$MARCH -mtune=$MARCH" || CCXX="-mtune=generic"
	CCXX="$CCXX -Os -pipe"
	#jtest -z "$NOLTO" -a "$1" = "lto" && CCXX="$CCXX -flto=$JOBS -fuse-linker-plugin"
	test -z "$NOLTO" -a "$1" = "lto" && CCXX="$CCXX -flto=auto -fuse-linker-plugin"
	export CC="gcc $CCXX"
	test "$2" == "noex" && CCXX="$CCXX -fno-exceptions -fno-rtti"
	export CXX="g++ $CCXX"
}

def_conf(){
	./configure \
		--prefix=/usr/local \
		--localstatedir=/var \
		--sysconfdir=/usr/local/etc \
		--disable-static \
		|| exit
}

def_make(){
	find . -name Makefile -type f -exec sed -i -e 's/-O2//g' {} \;
	make || exit
}

def_cmake(){
	cd src
	cmake .. || exit
	find . -name Makefile -type f -exec sed -i -e 's/-O2//g' {} \;
}

make_inst(){
	make install DESTDIR=$TCZ
}

make_dev(){
	make install DESTDIR=$TCZ-dev
}

def_move(){
	mkdir -p $TCZ/usr/local/lib
	mv $TCZ-dev/usr/local/lib/*.so* $TCZ/usr/local/lib
}

def_strip(){
	for a in $(find $TCZ* -type f); do
		file -b $a | grep -q '^ELF .*not stripped$' && strip --strip-unneeded $a
	done
}

set_perms(){
	for x in $(find $TCZTMP/$EXT -maxdepth 1 -name 'TCZ' -type d); do
		sudo chown -R root.root $x
		sudo chown -R root.staff $x/usr/local/tce.installed
		sudo chmod -R 775 $x/usr/local/tce.installed
	done
	for x in $(find $TCZTMP/$EXT -maxdepth 1 -name 'TCZ-*' -type d); do
		sudo chown -R root.root $x
		sudo chown -R root.staff $x/usr/local/tce.installed
		sudo chmod -R 775 $x/usr/local/tce.installed
	done
}

set_perms_inst(){
	sudo chown -R root.root $TCZ*
	sudo chown -R root.staff $TCZ/usr/local/tce.installed
	sudo chmod 775 $TCZ/usr/local/tce.installed/$EXT
}

squash_tcz(){
	for x in $(find $TCZTMP/$EXT -maxdepth 1 -name 'TCZ' -type d); do
		sudo mksquashfs $x $TCZTMP/$EXT/$EXT.tcz -noappend
	done
	for x in $(find $TCZTMP/$EXT -maxdepth 1 -name 'TCZ-*' -type d); do
		sudo mksquashfs $x $TCZTMP/$EXT/$EXT-${x##*-}.tcz -noappend
	done
}

copy_tcz(){
        for a in $TCZTMP/$1/*.tcz; do
                cp $a $STAGE
                cp $a $TCEOPT
		md5sum $a >$TCEOPT/$(basename $a).md5.txt
        done
}

# parameters
# 1: extension project name
# 2: source package base name
# 3: version appended to extension name
# 4: hint to find source package file
build_one(){
	PROJ="$1"
	PKGVER=""
	SRCHINT="$4"
	test -z "$2" && PKG="$PROJ" || { PKG="$2" ; PKGVER="$3" ; }
	SRC=$(basename $(find $SOURCE -maxdepth 1 -regex ".*/$PROJ[\.-]$SRCHINT.*" | sort | head -1))
	STYPE=${SRC##*.}
	SPROJ=${SRC#$PROJ*}

	echo "PKG=$PKG"
	echo "SRC=$SRC"
	echo "STYPE=$STYPE"
	cd $BUILD
	case $STYPE in
		zip)
			SVER=${SPROJ%.zip}
			echo "SVER=$SVER"
			sudo rm -rf $BUILD/$PROJ$SVER
			unzip -q -o $SOURCE/$SRC
			;;
		tgz)
			SVER=${SPROJ%.tgz}
			echo "SVER=$SVER"
			sudo rm -rf $BUILD/$PROJ$SVER
			tar xf $SOURCE/$SRC
			;;
		gz|bz2|xz)
			SVER=${SPROJ%.tar*}
			echo "SVER=$SVER"
			sudo rm -rf $BUILD/$PROJ$SVER
			mkdir -p $BUILD/$PROJ$SVER
			tar x -C $BUILD/$PROJ$SVER --strip-components 1 -f $SOURCE/$SRC
			;;
		lz)
			SVER=${SPROJ%.tar*}
			echo "SVER=$SVER"
			sudo rm -rf $BUILD/$PROJ$SVER
			lzip --decompress --keep --stdout $SOURCE/$SRC | tar x
			;;
		zst)
			SVER=${SPROJ%.tar*}
			echo "SVER=$SVER"
			sudo rm -rf $BUILD/$PROJ$SVER
			zstd --decompress --keep --stdout $SOURCE/$SRC | tar x
			;;
	esac
	cd $BUILD/$PROJ$SVER
	echo -e "\n=====  build-$PKG.sh =====\n"
	export RVER="${SVER#-*}"
	export EXT="$PKG$PKGVER"
	$PROD/build-$PKG.sh "$PKG" "$PKGVER"
	copy_tcz $EXT
}

