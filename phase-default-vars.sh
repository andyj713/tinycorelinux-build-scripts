BASE=/mnt/sda1/lamp
SOURCE=$BASE/src
test "$(uname -m)" = "x86_64" && KBITS=64 || KBITS=32
tcver=$(version)
TCVER=$KBITS-${tcver%.*}
LAMP=/mnt/sdb1/lamp$TCVER
BUILD=$LAMP/build
STAGE=$LAMP/stage
TCZTMP=$LAMP/tmp
TCZ=$TCZTMP/$EXT/TCZ

. $BASE/scripts/DEPS-$TCVER.sh
                                                                     
DBDEPS="openssl$SSLVER-dev postgresql-$PGVER-dev mariadb-$MDBVER-dev"

export MAKEFLAGS="-j12"

