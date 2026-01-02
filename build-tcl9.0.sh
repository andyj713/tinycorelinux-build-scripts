#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=tcl9.0

. $MEDIR/phase-default-vars.sh
. $MEDIR/phase-default-init.sh

DEPS="tzdata"

. $MEDIR/phase-default-deps.sh
. $MEDIR/phase-default-cc-opts.sh

export LDFLAGS="-lm"

./configure \
	--prefix=/usr/local \
	--localstatedir=/var \
	--disable-rpath \
	--enable-threads \
	--enable-64bit \
	--enable-load \
	--enable-dll-unloading \
	--without-tzdata \
	|| exit

. $MEDIR/phase-default-make.sh
. $MEDIR/phase-default-make-install.sh

mkdir -p $TCZ/usr/local/lib/tcl9.0
cp -r ../library/*.tcl $TCZ/usr/local/lib/tcl9.0
for a in cookiejar dde encoding http msgcat msgs opt platform; do
	cp -r ../library/$a $TCZ/usr/local/lib/tcl9.0
done

chmod -R ug+w $TCZ

mkdir -p $TCZ-doc/usr/local
mv $TCZ/usr/local/man $TCZ-doc/usr/local
mv $TCZ/usr/local/share $TCZ-doc/usr/local

mkdir -p $TCZ-dev/usr/local/lib
mkdir -p $TCZ-dev/usr/local/bin
mv $TCZ/usr/local/include $TCZ-dev/usr/local
mv $TCZ/usr/local/lib/pkgconfig $TCZ-dev/usr/local/lib
mv $TCZ/usr/local/lib/tcl*.sh $TCZ-dev/usr/local/lib
mv $TCZ/usr/local/bin/sqlite3_analyzer $TCZ-dev/usr/local/bin
CURDIR=$(pwd); cd $TCZ/usr/local/bin; ln -s tclsh9.0 tclsh; cd $CURDIR

for a in $(find $TCZ -name '*.a'); do
	b=$(echo $(dirname $a) | sed "s#$TCZ#$TCZ-dev#")
	mkdir -p $b
	mv $a $b
done
for a in $(find $TCZ -name '*.sh'); do
	b=$(echo $(dirname $a) | sed "s#$TCZ#$TCZ-dev#")
	mkdir -p $b
	mv $a $b
done

. $MEDIR/phase-default-strip.sh
. $MEDIR/phase-default-set-perms.sh
. $MEDIR/phase-default-squash-tcz.sh
