#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=$1$2

. $MEDIR/mkext-funcs.sh
set_vars
def_init

DEPS="$DBDEPS apr-dev apr-util-dev openldap-dev libxml2-dev net-snmp-dev unixODBC-dev
	libgd-dev curl-dev libwebp1-dev gmp-dev
	cyrus-sasl-dev fontconfig-dev libXft-dev libnghttp2-dev xorg-server-dev perl5"

case $TCVER in
	64-17 ) DEPS="$DEPS libvpx18-dev enchant2-dev pcre21042-dev icu74-dev lua-5.4-dev" ;;
	32-17 ) DEPS="$DEPS libvpx18-dev enchant2-dev pcre21042-dev icu70-dev lua-dev" ;;
	64-16 ) DEPS="$DEPS libvpx18-dev enchant2-dev pcre21042-dev icu74-dev lua-5.4-dev" ;;
	32-16 ) DEPS="$DEPS libvpx18-dev enchant2-dev pcre21042-dev icu70-dev lua-dev" ;;
	64-15 ) DEPS="$DEPS libvpx18-dev enchant2-dev pcre21042-dev icu74-dev lua-5.4-dev" ;;
	32-15 ) DEPS="$DEPS libvpx18-dev enchant2-dev pcre21042-dev icu70-dev lua-dev" ;;
	64-14 ) DEPS="$DEPS libvpx18-dev enchant2-dev icu74-dev lua-5.4-dev" ;;
	32-14 ) DEPS="$DEPS libvpx18-dev enchant2-dev icu70-dev lua-dev" ;;
	64-13 ) DEPS="$DEPS libvpx18-dev enchant2-dev icu67-dev lua-5.3-dev" ;;
	32-13 ) DEPS="$DEPS libvpx18-dev enchant-dev icu62-dev lua-dev" ;;
	64-12 ) DEPS="$DEPS libvpx18-dev enchant2-dev icu67-dev lua-5.3-dev" ;;
	32-12 ) DEPS="$DEPS libvpx18-dev enchant-dev icu62-dev lua-dev" ;;
	64-11 ) DEPS="$DEPS libvpx18-dev enchant2-dev icu61-dev lua-5.3-dev" ;;
	32-11 ) DEPS="$DEPS libvpx18-dev enchant-dev icu62-dev lua-dev" ;;
	64-10 ) DEPS="$DEPS libvpx17-dev enchant2-dev icu61-dev lua-5.3-dev" ;;
	32-10 ) DEPS="$DEPS libvpx17-dev enchant-dev icu62-dev lua-dev" ;;
	64-9 ) DEPS="$DEPS libvpx-dev enchant-dev icu61-dev lua-dev" ;;
	* ) DEPS="$DEPS libvpx-dev enchant-dev icu62-dev lua-dev" ;;
esac

def_deps
ccxx_opts lto noex

export C_INCLUDE_PATH=/usr/local/include/lua5.4:/usr/local/include/lua5.3

# move run dir from /var/logs to /var/run
for a in $(grep -I -r -l '_RUNTIMEDIR "/var/logs"' *)
        do sed -i 's#_RUNTIMEDIR "/var/logs"#_RUNTIMEDIR "/var/run"#' $a
done
# move log dir from /var/logs to /var/log/httpd
for a in $(grep -I -r -l '_LOGFILEDIR "/var/logs"' *)
        do sed -i 's#_LOGFILEDIR "/var/logs"#_LOGFILEDIR "/var/log/httpd"#' $a
done

# why is it /logs directory and not /log?
for a in $(grep -I -r -l '/logs' * | grep -v '^docs/' | cut -d: -f1 | sort -u); do sed -i -e 's#/logs#/log#g' $a; done

#make clean

export CPPFLAGS="-D_FILE_OFFSET_BITS=64"

./configure \
	--bindir=/usr/local/bin \
	--sbindir=/usr/local/sbin \
	--sysconfdir=/usr/local/etc/httpd \
	--localstatedir=/var \
	--enable-systemd=no \
	--enable-ssl \
	--enable-so \
	--enable-mods-shared=reallyall \
	--enable-mpms-shared=all \
	|| exit

find . -name Makefile -type f -exec sed -i 's/-g -O2//g' {} \;

d1='SUEXEC_BIN=\"/usr/local/sbin/suexec\"'
d2='DEFAULT_PIDLOG=\"/var/run/httpd.pid\"'
d3='DEFAULT_SCOREBOARD=\"/var/log/httpd/apache_runtime_status\"'
d4='DEFAULT_ERRORLOG=\"/var/log/httpd/error_log\"'

make CFLAGS="-D$d1 -D$d2 -D$d3 -D$d4" || exit

make_inst

rm -rf $TCZ/var
mkdir -p $TCZ-dev/usr/local/apache2
mkdir -p $TCZ-doc/usr/local/apache2

rm -f $TCZ/usr/local/etc/httpd/httpd.conf
rm -rf $TCZ/usr/local/etc/httpd/extra

mkdir -p $TCZ/usr/local/etc/init.d
cat >$TCZ/usr/local/etc/init.d/httpd <<'EOF'
#!/bin/sh
#
# Start/stop/restart/graceful[ly restart]/graceful[ly]-stop
# the Apache (httpd) web server.
#
# For information on these options, "man apachectl".

ACTLX=$(which apachectl)
test "$ACTLX" != "" && ACTLX="$ACTLX -k" || exit 1

case "$1" in
  'start')
    $ACTLX start
  ;;
  'stop')
    $ACTLX stop
    killall httpd
    # Remove both old and new .pid locations:
    rm -f /var/run/httpd.pid /var/run/httpd/httpd.pid
  ;;
  'force-restart')
    # Because sometimes restarting through apachectl just doesn't do the trick...
    $ACTLX stop
    killall httpd
    # Remove both old and new .pid locations:
    rm -f /var/run/httpd.pid /var/run/httpd/httpd.pid
    $ACTLX start
  ;;
  'restart')
    $ACTLX restart
  ;;
  'graceful')
    $ACTLX graceful
  ;;
  'graceful-stop')
    $ATCLX graceful-stop
  ;;
  *)
    echo "Usage: $0 {start|stop|force-restart|restart|graceful|graceful-stop}"
  ;;
esac
EOF
chmod 775 $TCZ/usr/local/etc/init.d/httpd

mkdir -p $TCZ/usr/local/etc/httpd/conf.d
mv $TCZ/usr/local/etc/httpd/original/extra $TCZ/usr/local/etc/httpd/original/conf.d
mv $TCZ/usr/local/etc/httpd/original/httpd.conf $TCZ/usr/local/etc/httpd/original/httpd.conf-sample

mv $TCZ/usr/local/apache2/include $TCZ-dev/usr/local/apache2
mv $TCZ/usr/local/apache2/build $TCZ-dev/usr/local/apache2
mkdir -p $TCZ-dev/usr/local/bin
mv $TCZ/usr/local/bin/apxs $TCZ-dev/usr/local/bin

mv $TCZ/usr/local/apache2/man $TCZ-doc/usr/local/share
mv $TCZ/usr/local/apache2/manual $TCZ-doc/usr/local/apache2

def_strip
set_perms
sudo chmod u+s $TCZ/usr/local/sbin/suexec

squash_tcz

