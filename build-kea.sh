#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=kea
PGVER=18

. $MEDIR/phase-default-vars.sh
. $MEDIR/phase-default-init.sh

DEPS="$DBDEPS log4cplus-dev boost-1.78-dev postgresql-$PGVER-dev"

. $MEDIR/phase-default-deps.sh

export CXXFLAGS="$CXXFLAGS -fexceptions" 

OL=s
if [ "$KBITS" == 32 ] ; then
        export CC="gcc -march=i686 -mtune=i686 -O$OL -pipe -fcommon"
        export CXX="g++ -march=i686 -mtune=i686 -O$OL -pipe -fexceptions"
else
        export CC="gcc -mtune=generic -O$OL -pipe -fcommon"
        export CXX="g++ -mtune=generic -O$OL -pipe -fexceptions"
fi

## fix source bug in kea-2.4.0
[ "$RVER" == "2.4.0" ] && sed -i -e '92s/;/);/' src/hooks/dhcp/pgsql_cb/pgsql_cb_impl.cc

DBPATH=/opt/kea/db
KEASRC=$(pwd)/src
./configure \
	--disable-static \
	--disable-rpath \
	--prefix=/usr/local \
	--sysconfdir=/usr/local/etc \
	--libdir=/usr/local/lib \
	--localstatedir=/var \
	--enable-shell \
	--with-openssl \
	--with-pgsql=/usr/local/pgsql$PGVER/bin/pg_config \
	--enable-pgsql-ssl \
	|| exit

#make clean
. $MEDIR/phase-default-make.sh
. $MEDIR/phase-make-install-dev.sh

#find $TCZ-dev/usr/local/lib -name '*.a' -exec rm {} \;

mkdir -p $TCZ/usr/local/tce.installed
cat << EOF > $TCZ/usr/local/tce.installed/$EXT
#!/bin/sh
[ -e $DBPATH ] || mkdir -p $DBPATH
ln -s $DBPATH /var/db
EOF

for a in $(grep -irl $KEASRC $TCZ-dev); do
	sed -i -e "/lamp/c \    printf \"Required file not found, try loading kea-dev extension\"" $a
done

rm -rf $TCZ-dev/usr/local/share/kea/scripts/mysql
mkdir -p $TCZ/usr/local/share/kea/scripts/pgsql
mv $TCZ-dev/usr/local/share/kea/api $TCZ/usr/local/share/kea
mv $TCZ-dev/usr/local/share/kea/scripts/admin-utils.sh $TCZ/usr/local/share/kea/scripts

mkdir -p $TCZ-doc/usr/local/share

for a in doc man; do mv $TCZ-dev/usr/local/share/$a $TCZ-doc/usr/local/share; done
for a in etc lib sbin; do mv $TCZ-dev/usr/local/$a $TCZ/usr/local; done
mv $TCZ-dev/var $TCZ

. $MEDIR/phase-default-strip.sh
. $MEDIR/phase-default-set-perms.sh
. $MEDIR/phase-default-squash-tcz.sh

