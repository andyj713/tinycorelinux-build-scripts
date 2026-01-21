#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

FULLVER=${PWD##*-}
PHPMAJ=${FULLVER%%.*}
MINPVER=${FULLVER#*.}
PHPMIN=${MINPVER%%.*}

EXTVER=$PHPMAJ.$PHPMIN
EXT=php-$EXTVER

OCI8_VER="3.4.0"
PDO_OCI_VER="1.2.0"

. $MEDIR/mkext-funcs.sh
set_vars
def_init

case $TCVER in
        64-17 ) XDEPS="libvpx18-dev ncursesw-utils pcre21042-dev icu74-dev" ;;
        32-17 ) XDEPS="libvpx18-dev pcre21042-dev icu70-dev" ;;
        64-16 ) XDEPS="libvpx18-dev ncursesw-utils pcre21042-dev icu74-dev" ;;
        32-16 ) XDEPS="libvpx18-dev pcre21042-dev icu70-dev" ;;
        64-15 ) XDEPS="libvpx18-dev ncursesw-utils pcre21042-dev icu74-dev" ;;
        32-15 ) XDEPS="libvpx18-dev pcre21042-dev icu70-dev" ;;
        64-14 ) XDEPS="libvpx18-dev ncursesw-utils pcre21042-dev icu74-dev" ;;
        32-14 ) XDEPS="libvpx18-dev pcre2-dev icu70-dev" ;;
        64-13 ) XDEPS="libvpx18-dev ncursesw-utils pcre21032-dev icu67-dev" ;;
        32-13 ) XDEPS="libvpx18-dev pcre2-dev icu62-dev" ;;
        64-12 ) XDEPS="libvpx18-dev ncursesw-utils pcre21032-dev icu67-dev" ;;
        32-12 ) XDEPS="libvpx18-dev pcre2-dev icu62-dev" ;;
        64-11 ) XDEPS="libvpx18-dev ncursesw-utils pcre21032-dev icu61-dev" ;;
        32-11 ) XDEPS="libvpx18-dev pcre2-dev icu62-dev" ;;
        64-10 ) XDEPS="libvpx17-dev ncursesw-utils pcre21032-dev icu61-dev" ;;
        32-10 ) XDEPS="libvpx17-dev pcre2-dev icu62-dev" ;;
        64-9 ) XDEPS="libvpx-dev pcre2-dev icu61-dev" ;;
        * ) XDEPS="libvpx-dev pcre2-dev icu-dev" ;;
esac

DEPS="$DBDEPS $XDEPS
 automake apache2.4 apache2.4-dev apr-dev apr-util-dev
 openldap-dev libxml2-dev libffi-dev net-snmp-dev libgd-dev
 curl-dev enchant2-dev libwebp1-dev libnet-dev gmp-dev
 aspell-dev cyrus-sasl-dev libxslt-dev libonig-dev libzip-dev
 libsodium-dev fontconfig-dev libtool-dev libtidy-dev
 ncursesw-dev perl5 unixODBC-dev tzdata sqlite3-dev gdbm-dev
 oracle-12.2-client acl-dev"

def_deps
ccxx_opts "" ""

sudo rm -f /usr/local/lib/php /usr/local/include/php /usr/local/bin/php*

echo $PATH | grep -q pgsql || export PATH=$PATH:/usr/local/mysql/bin:/usr/local/pgsql$PGVER/bin:/usr/local/oracle

# compiled-in extensions: date, pcre, reflection, spl, standard, hash, json, url, random

# stub for UTC-only internal timezone database
# requires external timezone database for other time zones
#cp $BASE/patches/timezone*.h ext/date/lib

# configure will fail if Apache httpd throws an error when trying to start
# make sure that /usr/local/etc/httpc/httpd.conf is correct

# apply fixes:

# busybox expr lack of support for -- meaning no more options
sed -i 's/expr -- /expr /g' configure

# fix for phpdbg libraries not added and passed to the linker
#grep -q 'PHPDBG_EXTRA_LIBS -lreadline -lncursesw' configure || \
#sed -i '\#BUILD_BINARY="sapi/phpdbg/phpdbg"#i \
# PHPDBG_EXTRA_LIBS="$PHPDBG_EXTRA_LIBS -lreadline -lncursesw"\
#' configure

# PHP will require X11 libraries even if you tell it --with-xpm-dir=no
# break xpm detection so it isn't required
#sed -i -e 's/gdImageCreateFromXpm/gdImageCreateFromXXXpm/g' configure
sed -i -e 's/"XBM Support", "enabled"/"XBM Support", "disabled"/' \
	-e 's/"XBM Support", 1/"XBM Support", 0/' ext/gd/gd.c
sed -i -e 's/"XPM Support", "enabled"/"XPM Support", "disabled"/' \
	-e 's/"XPM Support", 1/"XPM Support", 0/' ext/gd/gd.c

# TC curl 7.54.1 doesn't have GSSAPI support enabled
# break version check so it will not be assumed to exist
test ${tcver%.*} -lt 11 && sed -i -e 's/0x073601/0x073602/' ext/curl/interface.c

# fix socket location for mysql
for a in ext/mysqlnd/mysqlnd_connection.c ext/pdo_mysql/pdo_mysql.c ext/pdo_mysql/tests/pdo_mysql___construct_ini.phpt ; do
	sed -i 's#/tmp/mysql.sock#/var/run/mysql.sock#g' $a
done

# fix to make libxml a shared extension
sed -i '/if test "\$PHP_LIBXML" != "no"; then/{N;N;s/ext_shared=no/ext_shared=yes/}' configure

PHPOPS=""
test "$PHPMIN" -le 4 && PHPOPS="--enable-opcache=shared"
test "$PHPMIN" -le 3 && PHPOPS="$PHPOPS --with-pspell=shared"
EXTENSION_DIR=/usr/local/lib/php/extensions ./configure \
	--prefix=/usr/local \
	--sysconfdir=/usr/local/etc \
	--localstatedir=/var \
	--datadir=/usr/local/share \
	--mandir=/usr/local/share/man \
	--with-config-file-path=/usr/local/etc/php/ \
	--with-config-file-scan-dir=/usr/local/etc/php/extensions/ \
	--enable-shared \
	--enable-cgi \
	--enable-cli \
	--enable-fpm \
	--with-fpm-acl \
	--enable-phpdbg \
	--enable-phar=shared \
	--with-pear=shared,/usr/local/lib/php/pear \
	--enable-dmalloc=shared \
	--enable-libgcc \
	--with-system-ciphers \
	--enable-pdo=shared \
	--disable-rpath \
	--disable-static \
	--with-apxs2=/usr/local/bin/apxs \
	--with-libxml=shared \
	--enable-xml=shared \
	--enable-bcmath=shared \
	--with-bz2=shared \
	--enable-calendar=shared \
	--enable-ctype=shared \
	--with-curl=shared \
	--enable-dba=shared \
	--enable-dom=shared \
	--with-enchant=shared \
	--enable-exif=shared \
	--with-ffi=shared \
	--enable-fileinfo=shared \
	--enable-filter=shared \
	--enable-ftp=shared \
	--enable-gd=shared \
	--with-external-gd \
	--enable-gd-jis-conv \
	--with-gdbm=shared \
	--with-gettext=shared \
	--with-gmp=shared \
	--with-iconv=shared \
	--enable-intl=shared \
	--with-ldap=shared \
	--with-ldap-sasl \
	--enable-mbstring=shared \
	--enable-mbregex \
	--with-mhash=shared \
	--enable-mysqlnd=shared \
	--with-mysqli=shared,mysqlnd \
	--with-pdo-mysql=shared,mysqlnd \
	--with-mysql-sock=/var/run/mysql.sock \
	--with-openssl=shared \
	--enable-pcntl=shared \
	--with-external-pcre \
	--with-pcre-jit \
	--with-unixODBC=shared \
	--with-pdo-odbc=shared,unixODBC \
	--with-pgsql=shared,/usr/local/pgsql$PGVER \
	--with-pdo-pgsql=shared,/usr/local/pgsql$PGVER \
	--enable-posix=shared \
	--with-readline=shared \
	--enable-session=shared \
	--enable-shmop=shared \
	--with-snmp=shared \
	--enable-soap=shared \
	--enable-sockets=shared \
	--with-sodium=shared \
	--with-sqlite3=shared \
	--with-pdo-sqlite=shared \
	--enable-sysvmsg=shared \
	--enable-sysvsem=shared \
	--enable-sysvshm=shared \
	--with-tidy=shared \
	--enable-tokenizer=shared \
	--enable-simplexml=shared \
	--enable-xmlreader=shared \
	--enable-xmlwriter=shared \
	--with-xsl=shared \
	--enable-zend-signals \
	--with-zip=shared \
	--with-zlib=shared \
	--enable-zts \
	--with-pic=default \
	$PHPOPS || exit

# fix for libxml unresolved references, LIBXML_SHARED_LIBADD missing from Makefile
sed -i '\#shared_objects_libxml =#i \
LIBXML_SHARED_LIBADD = -L/usr/local/lib -lxml2' Makefile

sed -i '/^#define CONFIGURE_COMMAND/c\#define CONFIGURE_COMMAND " ./configure --localstatedir=/var --sysconfdir=/usr/local/etc"' main/build-defs.h

def_make

# fix module order for make test
sed -i '/^PHP_MODULES =/s# \$(phplibdir)/mysqlnd.la##' Makefile
sed -i '/^PHP_MODULES =/s# \$(phplibdir)/zlib.la # $(phplibdir)/zlib.la $(phplibdir)/mysqlnd.la #' Makefile

# make install will complain and die if a copy of the current httpd.conf
# file isn't in the install tree in the right place
mkdir -p $TCZ-dev/usr/local/etc/httpd
cp $BASE/contrib/httpd.conf $TCZ-dev/usr/local/etc/httpd

# pear requires xml and phar to install so make sure module gets loaded
sed -i '/^PEAR_INSTALL_FLAGS/s#$# -d extension_dir=$(top_builddir)/modules/ -d extension=libxml.so -d extension=xml.so -d extension=phar.so#' Makefile

# fix typo in pear install file bug #81653
#test "$PHPMIN" -le 3 && sed -i '9347s/-_/->_/' pear/install-pear-nozlib.phar
make install INSTALL_ROOT=$TCZ-dev DESTDIR=$TCZ-dev

# Oracle OCI and OpenLDAP have macro conflicts, so compile Oracle OCI after the rest are done
sudo rm -f /usr/local/lib/php /usr/local/include/php /usr/local/bin/php*
sudo ln -s $TCZ-dev/usr/local/lib/php /usr/local/lib/php
sudo ln -s $TCZ-dev/usr/local/include/php /usr/local/include/php
sudo cp $TCZ-dev/usr/local/bin/php* /usr/local/bin

# make Oracle OCI
cd ext
if [ "$PHPMIN" -ge 4 ] ; then
	tar xf $SOURCE/oci8-$OCI8_VER.tgz
	mv oci8-$OCI8_VER oci8
fi
cd oci8
/usr/local/bin/phpize
./configure --with-oci8=shared,instantclient,/usr/local/oracle
make install INSTALL_ROOT=$TCZ-dev
cd ../..
cp ext/oci8/modules/* modules

# make Oracle pdo_oci
cd ext
if [ "$PHPMIN" -ge 4 ] ; then
	tar xf $SOURCE/pdo_oci-$PDO_OCI_VER.tgz
	mv pdo_oci-$PDO_OCI_VER pdo_oci
fi
cd pdo_oci
/usr/local/bin/phpize
./configure --with-pdo-oci=shared,instantclient,/usr/local/oracle
make install INSTALL_ROOT=$TCZ-dev
cd ../..
cp ext/pdo_oci/modules/* modules

sudo rm -f /usr/local/lib/php /usr/local/include/php /usr/local/bin/php*

rm -rf $TCZ-dev/var
rm -rf $TCZ-dev/.[a-z]*
rm $TCZ-dev/usr/local/etc/httpd/httpd.conf.bak

mkdir -p $TCZ-cli/usr/local/bin
mv $TCZ-dev/usr/local/bin/php $TCZ-cli/usr/local/bin

mkdir -p $TCZ-cgi/usr/local/bin
mv $TCZ-dev/usr/local/bin/php-cgi $TCZ-cgi/usr/local/bin

#mkdir -p $TCZ-lsp/usr/local/bin
#mv $TCZ-dev/usr/local/bin/lsphp $TCZ-lsp/usr/local/bin

mkdir -p $TCZ-fpm/usr/local/etc/httpd/original/conf.d
cp $BASE/contrib/httpd-php8-fpm.conf $TCZ-fpm/usr/local/etc/httpd/original/conf.d
mv $TCZ-dev/usr/local/etc/php-fpm* $TCZ-fpm/usr/local/etc
mv $TCZ-dev/usr/local/sbin $TCZ-fpm/usr/local
mkdir -p $TCZ-fpm/usr/local/share
mv $TCZ-dev/usr/local/share/fpm $TCZ-fpm/usr/local/share
mkdir -p $TCZ-fpm/usr/local/etc/init.d
cat >$TCZ-fpm/usr/local/etc/init.d/php-fpm <<'EOF'
#!/bin/sh

php_fpm_BIN=$(which php-fpm)
php_fpm_CONF=/usr/local/etc/php-fpm.conf
php_fpm_PID=/var/run/php-fpm.pid


php_opts="--fpm-config $php_fpm_CONF --pid $php_fpm_PID"


wait_for_pid () {
	try=0

	while test $try -lt 35 ; do

		case "$1" in
			'created')
			if [ -f "$2" ] ; then
				try=''
				break
			fi
			;;

			'removed')
			if [ ! -f "$2" ] ; then
				try=''
				break
			fi
			;;
		esac

		echo -n .
		try=`expr $try + 1`
		sleep 1

	done

}

case "$1" in
	start)
		echo -n "Starting php-fpm "

		$php_fpm_BIN --daemonize $php_opts

		if [ "$?" != 0 ] ; then
			echo " failed"
			exit 1
		fi

		wait_for_pid created $php_fpm_PID

		if [ -n "$try" ] ; then
			echo " failed"
			exit 1
		else
			echo " done"
		fi
	;;

	stop)
		echo -n "Gracefully shutting down php-fpm "

		if [ ! -r $php_fpm_PID ] ; then
			echo "warning, no pid file found - php-fpm is not running ?"
			exit 1
		fi

		kill -QUIT `cat $php_fpm_PID`

		wait_for_pid removed $php_fpm_PID

		if [ -n "$try" ] ; then
			echo " failed. Use force-quit"
			exit 1
		else
			echo " done"
		fi
	;;

	status)
		if [ ! -r $php_fpm_PID ] ; then
			echo "php-fpm is stopped"
			exit 0
		fi

		PID=`cat $php_fpm_PID`
		if ps -p $PID | grep -q $PID; then
			echo "php-fpm (pid $PID) is running..."
		else
			echo "php-fpm dead but pid file exists"
		fi
	;;

	force-quit)
		echo -n "Terminating php-fpm "

		if [ ! -r $php_fpm_PID ] ; then
			echo "warning, no pid file found - php-fpm is not running ?"
			exit 1
		fi

		kill -TERM `cat $php_fpm_PID`

		wait_for_pid removed $php_fpm_PID

		if [ -n "$try" ] ; then
			echo " failed"
			exit 1
		else
			echo " done"
		fi
	;;

	restart)
		$0 stop
		$0 start
	;;

	reload)

		echo -n "Reload service php-fpm "

		if [ ! -r $php_fpm_PID ] ; then
			echo "warning, no pid file found - php-fpm is not running ?"
			exit 1
		fi

		kill -USR2 `cat $php_fpm_PID`

		echo " done"
	;;

	*)
		echo "Usage: $0 {start|stop|force-quit|restart|reload|status}"
		exit 1
	;;

esac
EOF
chmod 775 $TCZ-fpm/usr/local/etc/init.d/php-fpm

mkdir -p $TCZ-mod/usr/local/etc/httpd/original/conf.d
#mv $TCZ-dev/usr/local/etc/httpd/httpd.conf $TCZ-mod/usr/local/etc/httpd/original
rm $TCZ-dev/usr/local/etc/httpd/httpd.conf
cp $BASE/contrib/httpd-php8-mod.conf $TCZ-mod/usr/local/etc/httpd/original/conf.d
mv $TCZ-dev/usr/local/apache2 $TCZ-mod/usr/local
mv $TCZ-mod/usr/local/apache2/modules/libphp.so $TCZ-mod/usr/local/apache2/modules/mod_php8.so

mkdir -p $TCZ-ext/usr/local/lib/php
mv $TCZ-dev/usr/local/lib/php/extensions $TCZ-ext/usr/local/lib/php
mv $TCZ-dev/usr/local/etc $TCZ-ext/usr/local
mkdir -p $TCZ-ext/usr/local/etc/php/extensions
cp $BASE/contrib/php.ini-sample-$EXTVER $TCZ-ext/usr/local/etc/php

mkdir -p $TCZ-dev/usr/local/etc
rm -rf $TCZ-dev/usr/local/etc/httpd
rm -rf $TCZ-ext/usr/local/etc/httpd

def_strip
set_perms
squash_tcz

PHPDIR=$(pwd)
cd $BASE/php-tests
for a in $(find . -type f); do /bin/cp -f $a $PHPDIR/$a; done
cd $PHPDIR
