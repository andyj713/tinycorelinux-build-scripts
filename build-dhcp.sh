#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=dhcp

. $MEDIR/mkext-funcs.sh
set_vars
def_init

DEPS="perl5"

def_deps
test $KBITS = 32 && MARCH=i586
ccxx_opts "" noex

sed -i -e '/STD_CWARNINGS="$STD_CWARNINGS -Wall -Werror -fno-strict-aliasing"/s/ -Werror//' configure

export CFLAGS="$CFLAGS -std=gnu17"
#export MAKEFLAGS=""

DBPATH=/opt/dhcp/db
./configure \
	--prefix=/usr/local \
	--sysconfdir=/usr/local/etc \
	--libdir=/usr/local/lib \
	--localstatedir=/var \
	--with-srv-lease-file=$DBPATH/dhcpd.leases \
	--with-srv6-lease-file=$DBPATH/dhcpd6.leases \
	--with-cli-lease-file=$DBPATH/dhclient.leases \
	--with-cli6-lease-file=$DBPATH/dhclient6.leases \
	--with-randomdev=/dev/urandom \
	|| exit

#make clean
def_make
make_dev

mkdir -p $TCZ/usr/local/tce.installed

cat << EOF > $TCZ/usr/local/tce.installed/dhcp
#!/bin/sh
[ -e $DBPATH ] || mkdir -p $DBPATH
ln -s $DBPATH /var/db
EOF

mv $TCZ-dev/usr/local/bin $TCZ/usr/local
mv $TCZ-dev/usr/local/sbin $TCZ/usr/local
mv $TCZ-dev/usr/local/etc $TCZ/usr/local
cp client/scripts/linux $TCZ/usr/local/sbin/dhclient-script

def_strip
set_perms
squash_tcz


