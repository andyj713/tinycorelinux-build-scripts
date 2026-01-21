#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

FULLVER=${PWD##*-}
PGMAJ=${FULLVER%%.*}
MINPVER=${FULLVER#*.}
PGMIN=${MINPVER%%.*}

if [ $PGMAJ -eq 9 ] ; then
	EXT=postgresql-9.$PGMIN
	PGDIR=pgsql9$PGMIN
else
	EXT=postgresql-$PGMAJ
	PGDIR=pgsql$PGMAJ
fi

. $MEDIR/mkext-funcs.sh
set_vars
def_init

XDEPS=""
case $TCVER in
        64-17 ) XDEPS="icu74-dev glibc_i18n_locale python3.14-dev" ;;
        32-17 ) XDEPS="icu70-dev glibc_i18n_locale python3.14-dev" ;;
        64-16 ) XDEPS="icu74-dev glibc_i18n_locale python3.9-dev" ;;
        32-16 ) XDEPS="icu70-dev glibc_i18n_locale python3.9-dev" ;;
        64-15 ) XDEPS="icu74-dev glibc_i18n_locale python3.9-dev" ;;
        32-15 ) XDEPS="icu70-dev glibc_i18n_locale python3.9-dev" ;;
        64-14 ) XDEPS="icu74-dev glibc_i18n_locale python3.6-dev" ;;
        32-14 ) XDEPS="icu70-dev glibc_i18n_locale python3.6-dev" ;;
esac

DEPS="$XDEPS openssl$SSLVER-dev libxml2-dev libxslt-dev gettext-dev perl5 tzdata tcl8.6-dev"

def_deps
ccxx_opts lto noex

for a in $(grep -l -r 'define NAMEDATALEN' *); do
	sed -i -e 's/define NAMEDATALEN .*$/define NAMEDATALEN 128/' $a
done

export CFLAGS="$CFLAGS -std=gnu17"
export MAKEFLAGS=""

./configure \
	--prefix=/usr/local/$PGDIR \
	--localstatedir=/var \
	--with-uuid=e2fs \
	--with-libxml \
	--with-libxslt \
	--with-perl \
	--with-python \
	--with-tcl \
	--with-openssl \
	--with-ssl=openssl \
	--enable-nls \
	--with-system-tzdata=/usr/local/share/zoneinfo \
	|| exit

def_make
make_inst

cd contrib && make && make install DESTDIR=$TCZ && cd .. || exit

mkdir -p $TCZ-dev/usr/local/$PGDIR/bin
mkdir -p $TCZ-dev/usr/local/$PGDIR/lib
mkdir -p $TCZ-client/usr/local/$PGDIR/bin
mkdir -p $TCZ-client/usr/local/$PGDIR/lib

mv $TCZ/usr/local/$PGDIR/include $TCZ-dev/usr/local/$PGDIR
mv $TCZ/usr/local/$PGDIR/lib/pgxs $TCZ-dev/usr/local/$PGDIR/lib
mv $TCZ/usr/local/$PGDIR/lib/pkgconfig $TCZ-dev/usr/local/$PGDIR/lib
mv $TCZ/usr/local/$PGDIR/lib/*.a $TCZ-dev/usr/local/$PGDIR/lib
cp -a $TCZ/usr/local/$PGDIR/lib $TCZ-dev/usr/local/$PGDIR
mv $TCZ/usr/local/$PGDIR/bin/pg_config $TCZ-dev/usr/local/$PGDIR/bin

cp $TCZ/usr/local/$PGDIR/bin/psql $TCZ-client/usr/local/$PGDIR/bin
cp -a $TCZ/usr/local/$PGDIR/lib/libpq.so* $TCZ-client/usr/local/$PGDIR/lib

for x in '' '-client'; do
mkdir -p $TCZ$x/usr/local/tce.installed
cat << EOF > $TCZ$x/usr/local/tce.installed/$EXT$x
#!/bin/sh
[ \$(grep $PGDIR /etc/ld.so.conf) ] || echo /usr/local/$PGDIR/lib >> /etc/ld.so.conf
ldconfig -q
EOF
done

def_strip
set_perms
squash_tcz

