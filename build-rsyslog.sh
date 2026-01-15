#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=rsyslog

. $MEDIR/mkext-funcs.sh
set_vars
def_init

case $TCVER in
        64-17 ) PCREVER=21042; TLSVER=38 ;;
        32-17 ) PCREVER=21042; TLSVER=3.6 ;;
        64-16 ) PCREVER=21042; TLSVER=38 ;;
        32-16 ) PCREVER=21042; TLSVER=3.6 ;;
        64-15 ) PCREVER=21042; TLSVER=35 ;;
        32-15 ) PCREVER=21042; TLSVER=3.6 ;;
        64-14 ) PCREVER=21042; TLSVER=35 ;;
        32-14 ) PCREVER=21042; TLSVER=3.6 ;;
esac

DEPS="$DBDEPS pcre$PCREVER-dev jemalloc-dev net-snmp-dev curl-dev libgcrypt-dev
 autoconf automake autogen-dev
 iproute2 libestr-dev libfastjson-dev liblognorm-dev liblogging-dev libnet-dev libnet"

if [ "$TLSVER" != "" ] ; then
	DEPS="$DEPS gnutls$TLSVER-dev"
fi

def_deps
test $KBITS = 32 && MARCH=i586
ccxx_opts lto noex

echo $PATH | grep -q pgsql || export PATH=$PATH:/usr/local/mysql/bin:/usr/local/pgsql$PGVER/bin:/usr/local/oracle

sed -i -e 's#"/etc/rsyslog.conf"#"/usr/local/etc/rsyslog.conf"#' tools/rsyslogd.c

export PKG_CONFIG_PATH="/usr/local/pgsql$PGVER/lib/pkgconfig:/usr/local/mysql/lib/pkgconfig"

#export LDFLAGS="-latomic -latomic_ops -latomic_ops_gpl"

autoreconf --verbose --force --install || exit 1

#./autogen.sh \

#sed -i -e 's/mysql_init()/mysql_init(NULL)/' configure
#sed -i -e 's#\$MYSQL_CONFIG --libs#$MYSQL_CONFIG --libs | sed "s%/tmp/tcloop/mariadb-10.3-dev%%g"#' configure
#sed -i -e 's#\$MYSQL_CONFIG --cflags#$MYSQL_CONFIG --cflags | sed "s%/tmp/tcloop/mariadb-10.3-dev%%g"#' configure
#	--enable-fmpcre \

./configure ap_cv_atomic_builtins_64=yes \
	--prefix=/usr/local \
	--localstatedir=/var \
	--sysconfdir=/usr/local/etc \
	--enable-shared \
	--enable-regexp \
	--enable-fmhash \
	--enable-gnutls \
	--enable-klog \
	--enable-kmsg \
	--enable-libsystemd=no \
	--enable-debug=no \
	--enable-diagtools \
	--enable-usertools \
	--enable-inet \
	--enable-jemalloc \
	--enable-mysql \
	--enable-pgsql \
	--enable-snmp \
	--enable-uuid \
	--enable-omhttp \
	--enable-elasticsearch \
	--enable-openssl \
	--enable-libgcrypt \
	--enable-libzstd \
	--enable-rsyslogrt \
	--enable-rsyslogd \
	--enable-mmnormalize \
	--enable-mmjsonparse \
	--enable-mmaudit \
	--enable-mmanon \
	--enable-mmutf8fix \
	--enable-mmcount \
	--enable-mmsequence \
	--enable-mmfields \
	--enable-imfile \
	--enable-imptcp \
	--enable-impstats \
	--enable-omprog \
	--enable-omudpspoof \
	--enable-omstdout \
	--enable-pmlastmsg \
	--enable-pmcisconames \
	--enable-pmciscoios \
	--enable-pmnormalize \
	--enable-omruleset \
	--enable-mmsnmptrapd \
	--enable-omhttpfs \
	--enable-omtcl \
	|| exit

def_make
make_inst
def_strip

mkdir -p $TCZ/usr/local/etc
cat >$TCZ/usr/local/etc/rsyslog.conf-sample <<'EOF'
$WorkDirectory /srv/syslog/log/work

# This would queue _ALL_ rsyslog messages, i.e. slow them down to rate of DB ingest.
# Don't do that...
# $MainMsgQueueFileName mainq  # set file name, also enables disk mode

# We only want to queue for database writes.
$ActionQueueType LinkedList	# use asynchronous processing
$ActionQueueFileName dbq	# set file name, also enables disk mode
$ActionResumeRetryCount -1	# infinite retries on insert failure

# rsyslog Templates

template (name="DynFile" type="string" string="/srv/syslog2/log/syslog-%$now-utc%.log")
template (name="DynStat" type="string" string="/srv/syslog2/log/pstats-%$now-utc%.log")

# rsyslog RuleSets

action(type="omfile" dynafile="DynFile")
if $syslogtag contains 'rsyslogd-pstats' then {
        action(type="omfile" queue.type="linkedlist" queue.discardmark="980" name="pstats" dynafile="DynStat")
        stop
}

# Load Modules

module(load="imuxsock")	# provides support for local system logging (e.g. via logger command)
module(load="imklog")	# provides kernel logging support (previously done by rklogd)
module(load="immark")	# provides --MARK-- message capability
module(load="impstats")

# Provides UDP syslog reception
module(load="imudp")
input(type="imudp" port="514")

# Provides TCP syslog reception
module(load="imtcp")
input(type="imtcp" port="514")

# the project sample conf file is at https://github.com/rsyslog/rsyslog/blob/main/sample.conf

EOF

set_perms
squash_tcz

