#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=open-vm-tools

. $MEDIR/mkext-funcs.sh
set_vars
def_init

DEPS="glibc_apps libtool-dev procps-ng-dev
 glib2-dev gtkmm-dev gtk3-dev glibmm-dev gdk-pixbuf2-dev
 Xorg-7.7-3d-dev libSM-dev libXau-dev libdnet-dev"

# DEPS needed for deploypkg and pam: linux-pam-dev libmspack-dev

USETIRPC=" --without-tirpc"

case $TCVER in
	64-17 ) DEPS="$DEPS pcre21042-dev fuse-dev libtirpc-dev rpcsvc-proto" ; USETIRPC=" --with-tirpc" ;;
	32-17 ) DEPS="$DEPS pcre21042-dev fuse-dev libtirpc-dev rpcsvc-proto" ; USETIRPC=" --with-tirpc" ;;
	64-16 ) DEPS="$DEPS pcre21042-dev fuse-dev libtirpc-dev rpcsvc-proto" ; USETIRPC=" --with-tirpc" ;;
	32-16 ) DEPS="$DEPS pcre21042-dev fuse-dev libtirpc-dev rpcsvc-proto" ; USETIRPC=" --with-tirpc" ;;
	64-15 ) DEPS="$DEPS pcre21042-dev fuse-dev libtirpc-dev rpcsvc-proto" ; USETIRPC=" --with-tirpc" ;;
	32-15 ) DEPS="$DEPS pcre21042-dev fuse-dev libtirpc-dev rpcsvc-proto" ; USETIRPC=" --with-tirpc" ;;
	64-14 ) DEPS="$DEPS pcre-dev fuse-dev libtirpc-dev rpcsvc-proto" ; USETIRPC=" --with-tirpc" ;;
	32-14 ) DEPS="$DEPS pcre-dev fuse-dev libtirpc-dev rpcsvc-proto" ; USETIRPC=" --with-tirpc" ;;
	64-13 ) DEPS="$DEPS pcre-dev fuse-dev libtirpc-dev rpcsvc-proto" ; USETIRPC=" --with-tirpc" ;;
	32-13 ) DEPS="$DEPS pcre-dev fuse-dev libtirpc-dev rpcsvc-proto" ; USETIRPC=" --with-tirpc" ;;
	64-12 ) DEPS="$DEPS pcre-dev fuse-dev libtirpc-dev rpcsvc-proto" ; USETIRPC=" --with-tirpc" ;;
	32-12 ) DEPS="$DEPS pcre-dev fuse-dev libtirpc-dev rpcsvc-proto" ; USETIRPC=" --with-tirpc" ;;
	64-11 ) DEPS="$DEPS pcre-dev fuse-dev libtirpc-dev" ; USETIRPC=" --with-tirpc" ;;
	32-11 ) DEPS="$DEPS pcre-dev fuse-dev" ;;
	64-10 ) DEPS="$DEPS pcre-dev fuse" ;;  
	32-10 ) DEPS="$DEPS pcre-dev fuse fribidi-dev" ;;
        * ) DEPS="$DEPS libtirpc-dev pcre-dev fuse-dev" ; USETIRPC=" --with-tirpc" ;;
esac                          

def_deps
ccxx_opts "lto" ""
CC="$CC -std=gnu17"
CXX="$CXX -std=gnu17"

#if [ $(ldd --version | cut -d. -f2) -lt 32 ] ; then
	export RPCGEN=$(readlink -f $(which rpcgen))
	export RPCGENFLAGS="-Y $(dirname $(which cpp))"
#fi

#for a in $(grep -r -l vmware-tools *); do sed -i -e "s/vmware-tools/$EXT/g" $a; done

sed -i -e '/vmware_drv.so/s#/usr/lib#/usr/local/lib#'  services/plugins/resolutionSet/resolutionCommon.c

patch lib/system/systemLinux.c <<'EOF'
--- lib/system/systemLinux.c	2020-08-10 13:51:36.000000000 +0000
+++ lib/system/systemLinux.c-tc	2020-09-01 12:55:59.956736599 +0000
@@ -307,23 +307,9 @@
    char *cmd;
 
    if (reboot) {
-#if defined(sun)
-      cmd = "/usr/sbin/shutdown -g 0 -i 6 -y";
-#elif defined(USERWORLD)
-      cmd = "/bin/reboot";
-#else
-      cmd = "/sbin/shutdown -r now";
-#endif
+      cmd = "/usr/bin/exitcheck.sh reboot";
    } else {
-#if __FreeBSD__
-      cmd = "/sbin/shutdown -p now";
-#elif defined(sun)
-      cmd = "/usr/sbin/shutdown -g 0 -i 5 -y";
-#elif defined(USERWORLD)
-      cmd = "/bin/halt";
-#else
-      cmd = "/sbin/shutdown -h now";
-#endif
+      cmd = "/usr/bin/exitcheck.sh shutdown";
    }
    if (system(cmd) == -1) {
       fprintf(stderr, "Unable to execute %s command: \"%s\"\n",
EOF

#	--without-xerces \
#	--without-xmlsecurity \

### create Makefiles
./configure \
	--prefix=/usr/local \
	--localstatedir=/var \
	--sysconfdir=/etc \
	--disable-static \
	--without-xmlsec1 \
	--without-pam \
	--without-icu \
	--with-dnet \
	--with-x \
	--enable-libappmonitor \
	--enable-servicediscovery \
	--enable-resolutionkms \
	--enable-vmwgfxctrl \
	--disable-deploypkg \
	$USETIRPC || exit

### compile open-vm-tools

def_make
make_inst

### create tcz extension onload script

mkdir -p $TCZ/usr/local/tce.installed
sudo chown -R tc.staff $TCZ
cat > $TCZ/usr/local/tce.installed/$EXT <<EOF
#!/bin/sh

modprobe vmw_vsock_vmci_transport

if [ ! -f /etc/udev/rules.d/99-vmware-scsi-udev.rules ]; then
  cp -p /usr/local/etc/udev/rules.d/99-vmware-scsi-udev.rules /etc/udev/rules.d
  udevadm control --reload-rules
  udevadm trigger
fi

grep -q user_allow_other /etc/fuse.conf || echo "user_allow_other" >>/etc/fuse.conf
EOF

### create vmware-tools initialization script

mkdir -p $TCZ/usr/local/etc/init.d
cat > $TCZ/usr/local/etc/init.d/$EXT <<'EOF'
#!/bin/sh
# Start, stop, and restart vmtoolsd

case "$1" in
start)

# Interface check
NIF1=$(wc -l < /proc/net/dev)

# Load vmblock
vmblock_dev=/tmp/VMwareDnD
vmblockfusemntpt=/var/run/vmblock-fuse
[ -d $vmblock_dev ] || mkdir -m 1777 -p $vmblock_dev

if grep -q "$vmblockfusemntpt" /etc/mtab; then
	true
else
	mkdir -m 1777 -p $vmblockfusemntpt
	vmware-vmblock-fuse -o subtype=vmware-vmblock,default_permissions,allow_other $vmblockfusemntpt
fi

# Start vmtoolsd
if pidof vmtoolsd &>/dev/null; then
	echo vmtoolsd already running
else
	rm -f /var/run/vmtoolsd.pid
	/usr/local/bin/vmtoolsd --background=/var/run/vmtoolsd.pid
fi

# add the following to .xession after mouse initialization if .xsession doesn't run scripts in /usr/local/etc/X.d
# [ $(which vmware-checkvm) ] && # [ vmware-checkvm ] && # vmware-user

# Use ethtool to optimize vmxnet
	if which ethtool &> /dev/null; then
		for e in $(grep eth /proc/net/dev|cut -d: -f1); do
			ethtool -K $e gso on &> /dev/null
			ethtool -K $e tso on &> /dev/null
		done
	fi

# Start DHCP client for new interfaces
if ! grep -q nodhcp /proc/cmdline; then
	NIF2=$(wc -l < /proc/net/dev)
	if [ $NIF2 -gt $NIF1 ]; then
		  /etc/init.d/dhcp.sh
	fi
fi
exit 0
;;
stop)
	if pidof vmtoolsd &>/dev/null; then
		killall vmtoolsd
		echo stopped vmtoolsd
		exit 0
	else
		echo vmtoolsd is not running
		exit 1
	fi
;;
restart)
	$0 stop
	$0 start
;;
status)
	if pidof vmtoolsd &>/dev/null; then
		echo vmtoolsd is running
		exit 0
	else
		echo vmtoolsd is not running
		exit 1
	fi
;;
*)
	echo "Usage: $0 (start|stop|restart|status)"
	exit 1
;;
esac
EOF
chmod 775 $TCZ/usr/local/etc/init.d/$EXT

mkdir -p $TCZ/etc/profile.d
cat >$TCZ/etc/profile.d/$EXT.sh <<'EOF'
# Mount vmhgfs now a userspace program
# /dev/fuse needs to be writable to user
# /mnt/hgfs-* needs to be a directory and 777

if [ vmware-checkvm ]; then
	for a in $(vmware-hgfsclient); do
		vmhgfsmntpt=/mnt/hgfs/$a
		if grep -q $vmhgfsmntpt /etc/mtab; then
			sudo umount -f -l $vmhgfsmntpt
		fi
		if [ -e $vmhgfsmntpt ]; then
			if [ -d $vmhgfsmntpt ]; then
				sudo chmod 777 $vmhgfsmntpt
			else
				sudo rm -f $vmhgfsmntpt
				sudo mkdir -m 777 -p $vmhgfsmntpt
			fi
		else
			sudo mkdir -m 777 -p $vmhgfsmntpt
		fi
		vmhgfs-fuse -o allow_other .host:/$a $vmhgfsmntpt
	done
fi
EOF

mkdir -p $TCZ-desktop/usr/local/etc/X.d
cat >$TCZ-desktop/usr/local/etc/X.d/$EXT <<'EOF'
[ $(which vmware-checkvm) ] && [ vmware-checkvm ] && vmware-user &
EOF

### create -dev directory if anyone ever wants it

mkdir -p $TCZ-dev/usr/local/lib
#mv $TCZ/usr/local/share $TCZ-dev/usr/local
mv $TCZ/usr/local/include $TCZ-dev/usr/local
mv $TCZ/usr/local/lib/pkgconfig $TCZ-dev/usr/local/lib
mkdir -p $TCZ-dev/etc
mv $TCZ/etc/pam.d $TCZ-dev/etc
for a in $(find $TCZ -name '*.la'); do
        b=$(echo $(dirname $a) | sed "s#$TCZ#$TCZ-dev#")
        mkdir -p $b
        mv $a $b
done

### fix up files

mv $TCZ/usr/bin/vm-support $TCZ/usr/local/bin
mv $TCZ/lib/udev $TCZ/usr/local/etc
mkdir -p $TCZ/etc/vmware-tools/scripts/poweroff-vm-default.d
mkdir -p $TCZ/etc/vmware-tools/scripts/poweron-vm-default.d
mkdir -p $TCZ/etc/vmware-tools/scripts/suspend-vm-default.d
mkdir -p $TCZ/etc/vmware-tools/scripts/resume-vm-default.d

### move user parts into desktop extension

mv $TCZ/etc/xdg $TCZ-desktop/usr/local/etc

mkdir -p $TCZ-desktop/usr/local/lib/$EXT/plugins/vmsvc
mv $TCZ/usr/local/lib/$EXT/plugins/vmusr $TCZ-desktop/usr/local/lib/$EXT/plugins
mv $TCZ/usr/local/lib/$EXT/plugins/vmsvc/libresolutionKMS.so $TCZ-desktop/usr/local/lib/$EXT/plugins/vmsvc

mkdir -p $TCZ-desktop/usr/local/bin
mv $TCZ/usr/local/bin/vmware-user* $TCZ-desktop/usr/local/bin
mv $TCZ/usr/local/bin/vmwgfxctrl $TCZ-desktop/usr/local/bin

rm -rf $TCZ/lib
rm -rf $TCZ/sbin
rm -rf $TCZ/usr/bin

### set file permissions and ownership

def_strip

chmod -R 755 $TCZ
chmod -R 755 $TCZ-desktop
sudo chown -R root.root $TCZ*
sudo chown -R root.staff $TCZ*/usr/local/tce.installed
sudo chmod -R g+w $TCZ/usr/local/tce.installed
sudo chmod u+s $TCZ-desktop/usr/local/bin/vmware-user-suid-wrapper

squash_tcz

