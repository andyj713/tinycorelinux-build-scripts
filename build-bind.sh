#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=bind

. $MEDIR/phase-default-vars.sh
. $MEDIR/phase-default-init.sh

PYDEPS=""
NOPY=""
case $TCVER in
	64-16 ) PYDEPS="python3.9-dev py3.9-ply" ;;
	32-16 ) PYDEPS="python3.6-dev python3.6-ply" ;;
	64-15 ) PYDEPS="python3.9-dev py3.9-ply" ;;
	32-15 ) PYDEPS="python3.6-ply" ;;
	64-14 ) PYDEPS="python3.6-ply" ;;
	32-14 ) PYDEPS="python3.6-ply" ;;
	64-13 ) PYDEPS="python3.6-ply" ;;
	32-13 ) PYDEPS="python3.6-ply" ;;
	64-12 ) PYDEPS="python3.6-ply" ;;
	32-12 ) PYDEPS="python3.6-ply" ;;
	64-11 ) PYDEPS="python3.6-ply" ;;
	32-11 ) PYDEPS="python3.6-ply" ;;
	64-10 ) PYDEPS="python-ply" ;;
	32-10 ) PYDEPS="python-ply" ;;
	* ) NOPY="--without-python" ;;
esac

DEPS="$DBDEPS $PYDEPS perl5 libuv-dev libcap-dev libpcap-dev jemalloc-dev
	readline-dev zlib_base-dev libnghttp2-dev liburcu-dev"

. $MEDIR/phase-default-deps.sh
. $MEDIR/phase-default-cc-opts.sh

./configure \
	--prefix=/usr/local \
	--sysconfdir=/usr/local/etc \
	--libdir=/usr/local/lib \
	--localstatedir=/var \
	--enable-shared \
	--disable-static \
	--with-openssl=/usr/local \
	--with-readline=readline \
	--enable-full-report \
	--enable-linux-caps \
	$NOPY || exit

. $MEDIR/phase-default-make.sh
. $MEDIR/phase-default-make-install.sh

rm -rf $TCZ/var

mkdir -p $TCZ-dev/usr/local/lib
mkdir -p $TCZ-doc/usr/local
mkdir -p $TCZ/usr/local/etc/init.d
cat >$TCZ/usr/local/etc/init.d/bind <<'EOF'
#!/bin/sh
# Start/stop/restart the BIND name server daemon (named).


# Start bind. In the past it was more secure to run BIND as a non-root
# user (for example, with '-u daemon'), but the modern version of BIND
# knows how to use the kernel's capability mechanism to drop all root
# privileges except the ability to bind() to a privileged port and set
# process resource limits, so -u should not be needed.  If you wish to
# use it anyway, chown the /var/run/named and /var/named directories to
# the non-root user.

# You might also consider running BIND in a "chroot jail",
# a discussion of which may be found in
# /usr/doc/Linux-HOWTOs/Chroot-BIND-HOWTO.
 
# One last note:  rndc has a lot of other nice features that it is not
# within the scope of this start/stop/restart script to support.
# For more details, see "man rndc" or just type "rndc" to see the options.

# Start BIND.  As many times as you like.  ;-)
# Seriously, don't run "rc.bind start" if BIND is already
# running or you'll get more than one copy running.

NAMEDX=$(which named)
RNDCX=$(which rndc)
test "$NAMEDX" != "" -a "$RNDCX" != "" || exit 1
NAMED_OPTIONS="-u named"
RNDC_OPTIONS=""

bind_start() {
  if [ -x $NAMEDX ]; then
    echo "Starting BIND:  $NAMEDX $NAMED_OPTIONS"
    $NAMEDX $NAMED_OPTIONS
    sleep 1
  fi
  if ! ps axc | grep -q named ; then
    echo "WARNING:  named did not start."
    echo "Attempting to start named again:  $NAMEDX $NAMED_OPTIONS"
    $NAMEDX $NAMED_OPTIONS
    sleep 1
    if ps axc | grep -q named ; then
      echo "SUCCESS:  named started."
    else
      echo "FAILED:  Sorry, a second attempt to start named has also failed."
      echo "There may be a configuration error that needs fixing.  Good luck!"
    fi
  fi
}

# Stop all running copies of BIND ($NAMEDX):
bind_stop() {
  echo "Stopping BIND:  $RNDCX $RDNC_OPTIONS stop"
  $RNDCX $RDNC_OPTIONS stop
  # A problem with using "/usr/local/sbin/rndc stop" is that if you
  # managed to get multiple copies of named running it will
  # only stop one of them and then can't stop the others even
  # if you run it again.  So, after doing things the nice way
  # we'll do them the old-fashioned way.  If you don't like
  # it you can comment it out, but unless you have a lot of
  # other programs you run called "named" this is unlikely
  # to have any ill effects:
  sleep 1
  if ps axc | grep -q named ; then
    echo "Using "killall named" on additional BIND processes..."
    /bin/killall named 2> /dev/null
  fi
}

# Reload BIND:
bind_reload() {
  $RNDCX $RDNC_OPTIONS reload
}

# Restart BIND:
bind_restart() {
  bind_stop
  bind_start
}

# Get BIND status:
bind_status() {
  $RNDCX $RDNC_OPTIONS status
}

case "$1" in
'start')
  bind_start
  ;;
'stop')
  bind_stop
  ;;
'reload')
  bind_reload
  ;;
'restart')
  bind_restart
  ;;
'status')
  bind_status
  ;;
*)
  echo "usage $0 start|stop|reload|restart|status"
esac
EOF
chmod 775 $TCZ/usr/local/etc/init.d/bind

mv $TCZ/usr/local/share $TCZ-doc/usr/local
mv $TCZ/usr/local/include $TCZ-dev/usr/local
mv $TCZ/usr/local/lib/*.la $TCZ-dev/usr/local/lib
#rm $TCZ/usr/local/lib/*.la

. $MEDIR/phase-default-strip.sh
. $MEDIR/phase-default-set-perms.sh
. $MEDIR/phase-default-squash-tcz.sh

