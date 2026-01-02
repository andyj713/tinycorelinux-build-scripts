#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=nginx

. $MEDIR/phase-default-vars.sh
. $MEDIR/phase-default-init.sh

case $TCVER in
        64-16 ) XDEPS="pcre21042-dev giflib7-dev tiff-dev" ;;
        32-16 ) XDEPS="pcre21042-dev giflib7-dev libtiff-dev" ;;
        64-15 ) XDEPS="pcre21042-dev giflib7-dev tiff-dev" ;;
        32-15 ) XDEPS="pcre21042-dev giflib7-dev libtiff-dev" ;;
        64-14 ) XDEPS="pcre-dev giflib7-dev tiff-dev" ;;
        32-14 ) XDEPS="pcre-dev giflib7-dev libtiff-dev" ;;
        64-13 ) XDEPS="pcre-dev giflib7-dev tiff-dev" ;;
        32-13 ) XDEPS="pcre-dev giflib7-dev libtiff-dev" ;;
        64-12 ) XDEPS="pcre-dev giflib7-dev tiff-dev" ;;
        32-12 ) XDEPS="pcre-dev giflib7-dev libtiff-dev" ;;
        64-11 ) XDEPS="pcre-dev giflib7-dev tiff-dev" ;;
        32-11 ) XDEPS="pcre-dev giflib7-dev libtiff-dev" ;;
        64-10 ) XDEPS="pcre-dev giflib7-dev tiff-dev" ;;
        32-10 ) XDEPS="pcre-dev giflib7-dev libtiff-dev" ;;
        64-9 ) XDEPS="pcre-dev giflib-dev tiff-dev" ;;
        32-9 ) XDEPS="pcre-dev giflib-dev libtiff-dev" ;;
        * ) XDEPS="pcre-dev" ;;
esac

DEPS="$DBDEPS $XDEPS expat2-dev fontconfig-dev freetype-dev harfbuzz-dev libaio-dev
 libgd-dev libjpeg-turbo-dev libpng-dev libwebp1-dev libxml2-dev
 libxslt-dev zlib_base-dev"

. $MEDIR/phase-default-deps.sh
. $MEDIR/phase-default-cc-opts.sh

export CCFLAGS="$CCFLAGS -shared -fPIC"
export CCXFLAGS="$CCXFLAGS -shared -fPIC"

#	--with-pcre=/usr/local \
#	--with-zlib=/usr/local \
#	--with-openssl=/usr/local \

./configure \
	--prefix=/usr/local \
	--sbin-path=/usr/local/sbin/nginx \
	--modules-path=/usr/local/lib/nginx/modules \
	--conf-path=/usr/local/etc/nginx/nginx.conf \
	--error-log-path=/var/log/nginx/error.log \
	--pid-path=/var/run/nginx.pid \
	--lock-path=/tmp/nginx/lock \
	--user=nobody \
	--group=nogroup \
	--with-threads \
	--with-file-aio \
	--with-compat \
	--with-http_ssl_module \
	--with-http_v2_module \
	--with-http_realip_module \
	--with-http_addition_module \
	--with-http_xslt_module=dynamic \
	--with-http_image_filter_module=dynamic \
	--with-http_sub_module \
	--with-http_dav_module \
	--with-http_flv_module \
	--with-http_mp4_module \
	--with-http_gunzip_module \
	--with-http_gzip_static_module \
	--with-http_auth_request_module \
	--with-http_random_index_module \
	--with-http_secure_link_module \
	--with-http_degradation_module \
	--with-http_slice_module \
	--with-http_stub_status_module \
	--http-log-path=/var/log/nginx \
	--http-client-body-temp-path=/tmp/nginx/client \
	--http-proxy-temp-path=/tmp/nginx/proxy \
	--http-fastcgi-temp-path=/tmp/nginx/fastcgi \
	--http-uwsgi-temp-path=/tmp/nginx/uwsgi \
	--http-scgi-temp-path=/tmp/nginx/scgi \
	--with-mail=dynamic \
	--with-mail_ssl_module \
	--with-stream=dynamic \
	--with-stream_ssl_module \
	--with-stream_realip_module \
	--with-stream_ssl_preread_module \
	|| exit

. $MEDIR/phase-default-make.sh
. $MEDIR/phase-default-make-install.sh

mkdir -p $TCZ/usr/local/etc/init.d
cat >$TCZ/usr/local/etc/init.d/nginx <<'EOF'
#!/bin/sh

NGINX=$(which nginx)
test "$NGINX" != "" || exit 1

start() {
    if [ ! -f /var/run/nginx.pid ]; then
        $NGINX
    fi
}

stop() {
    if [ -f /var/run/nginx.pid ]; then
        $NGINX -s stop
    fi
}

reopen() {
    if [ -f /var/run/nginx.pid ]; then
        $NGINX -s reopen
    fi
}

reload() {
    if [ -f /var/run/nginx.pid ]; then
        $NGINX -s reload
    fi
}

status() {
    if [ -e /var/run/nginx.pid ]; then
        echo -e "\nnginx is running.\n"
        exit 0
    else
        echo -e "\nnginx is not running.\n"
        exit 1
    fi
}

case $1 in
    start) start
        ;;
    stop) stop
        ;;
    status) status
        ;;
    reopen) reopen
        ;;
    reload) reload
        ;;
    *) echo -e "\n$0 [start|stop|reopen|reload|status]\n"
        ;;
esac
EOF
chmod 775 $TCZ/usr/local/etc/init.d/nginx

mkdir -m 775 -p $TCZ/usr/local/tce.installed
cat >$TCZ/usr/local/tce.installed/nginx <<'EOF'
#!/bin/sh

rm -rf /tmp/nginx
mkdir -m 700 -p /tmp/nginx
chown nobody /tmp/nginx
EOF
chmod 775 $TCZ/usr/local/tce.installed/nginx

#mkdir -p $TCZ-doc/usr/local
#mv $TCZ/usr/local/share $TCZ-doc/usr/local
#mv $TCZ/usr/local/man $TCZ-doc/usr/local

mv $TCZ/usr/local/html $TCZ/usr/local/lib/nginx
mkdir -p $TCZ/usr/local/etc/nginx/original
for a in $TCZ/usr/local/etc/nginx/*.default; do rm $TCZ/usr/local/etc/nginx/$(basename $a .default); done
mv $TCZ/usr/local/etc/nginx/*.default $TCZ/usr/local/etc/nginx/original
chmod 777 $TCZ/var/log/nginx

. $MEDIR/phase-default-strip.sh
. $MEDIR/phase-default-set-perms.sh

sudo chown -R root.staff $TCZ/usr/local/tce.installed

. $MEDIR/phase-default-squash-tcz.sh

