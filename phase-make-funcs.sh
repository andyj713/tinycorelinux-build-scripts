SCRIPTS=$BASE/scripts                           
TCEOPT=/etc/sysconfig/tcedir/optional
                                         
PROD="$SCRIPTS"                          

copy_tcz(){
        for a in $TCZTMP/$1/*.tcz; do
                cp $a $STAGE
                cp $a $TCEOPT
#		md5sum $a >$TCEOPT/$(basename $a).md5.txt
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

#sudo cp $BASE/la-files/* /usr/local/lib

