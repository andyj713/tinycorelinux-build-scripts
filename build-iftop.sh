#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=iftop

. $MEDIR/phase-default-vars.sh
. $MEDIR/phase-default-init.sh

DEPS="perl5 libpcap-dev ncursesw-dev"

. $MEDIR/phase-default-deps.sh

. $MEDIR/phase-default-cc-opts.sh

export CFLAGS="$CFLAGS -fcommon"

sudo ln -fs /usr/local/include/ncursesw/ncurses.h /usr/local/include/ncursesw.h

#grep -q 'curses ncurses' configure && sed -i -e '/curses ncurses/s/curses ncurses/ncursesw/' configure

. $MEDIR/phase-default-config.sh

for a in $(grep -l -r '<ncurses.h>' *); do sed -i 's#<ncurses.h>#<ncursesw/ncurses.h>#' $a; done
for a in $(grep -l -r '<curses.h>' *); do sed -i 's#<curses.h>#<ncursesw/curses.h>#' $a; done

. $MEDIR/phase-default-make.sh
. $MEDIR/phase-default-make-install.sh
. $MEDIR/phase-default-strip.sh
. $MEDIR/phase-default-set-perms.sh
. $MEDIR/phase-default-squash-tcz.sh

