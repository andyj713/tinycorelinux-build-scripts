#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=dhcp

. $MEDIR/phase-default-vars.sh
. $MEDIR/phase-default-init.sh

DEPS="perl5"

. $MEDIR/phase-default-deps.sh
test $KBITS = 32 && MARCH=i586
. $MEDIR/phase-cc-opts-no-flto.sh

sed -i -e '/STD_CWARNINGS="$STD_CWARNINGS -Wall -Werror -fno-strict-aliasing"/s/ -Werror//' configure

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
. $MEDIR/phase-default-make.sh
. $MEDIR/phase-make-install-dev.sh

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

. $MEDIR/phase-default-strip.sh
. $MEDIR/phase-default-set-perms.sh
. $MEDIR/phase-default-squash-tcz.sh


