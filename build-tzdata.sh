#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=tzdata

. $MEDIR/mkext-funcs.sh
set_vars
def_init

DEPS="lzip"

def_deps
ccxx_opts lto noex

make USRDIR=usr/local DESTDIR=$TCZ install || exit

mkdir -m 775 -p $TCZ/usr/local/tce.installed
cat >$TCZ/usr/local/tce.installed/$EXT <<'EOF'
#!/bin/sh
# tzdata.tcz - startup script
# link /etc/localtime to the user's preferred timezone
#
# CHANGES
#   20150921 - first version, at suggestion of juanito; dentonlt
#   20151001 - append links for zoneinfo in /usr/share/ (ntpd looks here?); dentonlt
#

if [ -e /etc/sysconfig/timezone ]; then

# for each member of the timezone string, do a find to descending into zoneinfo data 
	TZ="$(/bin/cat /etc/sysconfig/timezone | /usr/bin/cut -f2 -d= | /bin/sed 's#/# #g')"
	F=/usr/local/share/zoneinfo
	for LOC in $TZ; do
		F="$(/usr/bin/find $F -maxdepth 1 -name $LOC)"    
		[ -z "$F" ] && F=/usr/local/share/zoneinfo/UTC 
	done 

	sudo /bin/ln -s $F /etc/localtime
fi

sudo ln -s /usr/local/share/zoneinfo /usr/share/zoneinfo
sudo ln -s /usr/local/share/zoneinfo-leaps /usr/share/zoneinfo-leaps
sudo ln -s /usr/local/share/zoneinfo-posix /usr/share/zoneinfo-posix
EOF

mkdir -p $TCZ-doc/usr/local/share
mv $TCZ/usr/local/share/man $TCZ-doc/usr/local/share
mkdir -p $TCZ-bin/usr/local
mv $TCZ/usr/local/bin $TCZ-bin/usr/local
mv $TCZ/usr/local/sbin $TCZ-bin/usr/local
mv $TCZ/usr/local/lib $TCZ-bin/usr/local
rm -rf $TCZ/etc

def_strip
set_perms
squash_tcz

