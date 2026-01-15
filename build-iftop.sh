#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=iftop

. $MEDIR/mkext-funcs.sh
set_vars
def_init

DEPS="perl5 libpcap-dev ncursesw-dev"

def_deps

ccxx_opts lto noex

export CFLAGS="$CFLAGS -fcommon -std=gnu17"

sudo ln -fs /usr/local/include/ncursesw/ncurses.h /usr/local/include/ncursesw.h

#grep -q 'curses ncurses' configure && sed -i -e '/curses ncurses/s/curses ncurses/ncursesw/' configure

def_conf

for a in $(grep -l -r '<ncurses.h>' *); do sed -i 's#<ncurses.h>#<ncursesw/ncurses.h>#' $a; done
for a in $(grep -l -r '<curses.h>' *); do sed -i 's#<curses.h>#<ncursesw/curses.h>#' $a; done

def_make
make_inst
def_strip
set_perms
squash_tcz

