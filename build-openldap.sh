#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=openldap

. $MEDIR/mkext-funcs.sh
set_vars
def_init

DEPS="$DBDEPS libltdl groff unixODBC-dev cyrus-sasl-dev libtool-dev perl5"

def_deps
ccxx_opts "" noex
ccxx_opts lto noex

# break ICU detection so it will not be required
sed -i 's/ol_cv_lib_icu=yes/ol_cv_lib_icu=no/' configure

#make clean
./configure \
	--prefix=/usr/local \
	--localstatedir=/var \
	--sysconfdir=/usr/local/etc \
	--enable-dynamic \
	--enable-shared \
	--disable-static \
	--disable-debug \
	--enable-syslog \
	--enable-ipv6 \
	--enable-local \
	--enable-slapd \
	--enable-cleartext \
	--enable-crypt \
	--enable-spasswd \
	--enable-rlookups \
	--enable-modules=yes \
	--disable-bdb \
	--disable-hdb \
	--disable-ndb \
	--enable-ldap=mod \
	--enable-mdb=yes \
	--enable-meta=mod \
	--enable-monitor=mod \
	--enable-passwd=mod \
	--enable-relay=mod \
	--enable-sock=mod \
	--enable-sql=mod \
	--enable-overlays=mod \
	--with-cyrus-sasl \
	--with-tls=openssl \
	--with-threads \
	--with-odbc=unixodbc \
	|| exit

make depend || exit

def_make
make || exit

make_inst

rm -rf $TCZ/opt/run

mkdir -m 775 -p $TCZ/usr/local/tce.installed
cat >$TCZ/usr/local/tce.installed/$EXT <<EOF
#!/bin/sh
#
[ -e /usr/local/etc/$EXT/ldap.conf ] || cp /usr/local/etc/$EXT/ldap.conf.default /usr/local/etc/$EXT/ldap.conf
[ -e /usr/local/etc/$EXT/slapd.conf ] || cp /usr/local/etc/$EXT/slapd.conf.default /usr/local/etc/$EXT/slapd.conf
[ -e /usr/local/etc/$EXT/slapd.ldif ] || cp /usr/local/etc/$EXT/slapd.ldif.default /usr/local/etc/$EXT/slapd.ldif
EOF

mkdir -p $TCZ-dev/usr/local/lib
mv $TCZ/usr/local/include $TCZ-dev/usr/local
mv $TCZ/usr/local/lib/*.a $TCZ-dev/usr/local/lib
mv $TCZ/usr/local/lib/*.la $TCZ-dev/usr/local/lib
#rm $TCZ/usr/local/lib/*.la

mkdir -p $TCZ-doc/usr/local
mv $TCZ/usr/local/share $TCZ-doc/usr/local

rm $TCZ/usr/local/etc/$EXT/ldap.conf
rm $TCZ/usr/local/etc/$EXT/slapd.conf
rm $TCZ/usr/local/etc/$EXT/slapd.ldif

def_strip
set_perms_inst
squash_tcz

