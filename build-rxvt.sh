#!/bin/sh
#
ME=$(readlink -f "$0")
export MEDIR=${ME%/*}

EXT=rxvt

. $MEDIR/phase-default-vars.sh
. $MEDIR/phase-default-init.sh

#XP="--enable-transparency --enable-pixbuf"
XP="--disable-transparency --disable-pixbuf"
case "$RVER" in
	9.31) DEPS="xorg-proto Xorg-7.7-dev fontconfig-dev libXft-dev ncursesw-utils" ;;
	9.30) DEPS="gdk-pixbuf2-dev xorg-proto Xorg-7.7-dev fontconfig-dev libXft-dev ncursesw-utils" ;;
	9.26) DEPS="gdk-pixbuf2-dev xorg-proto Xorg-7.7-dev fontconfig-dev libXft-dev ncursesw-utils" ;;
	9.22) DEPS="xorg-proto Xorg-7.7-dev fontconfig-dev libXft-dev ncursesw-utils" ;;
	*) DEPS="" ;;
esac

. $MEDIR/phase-default-deps.sh
. $MEDIR/phase-cc-opts-no-flto-excp.sh

for a in $(find $SOURCE/$EXT-patches -maxdepth 1 -name "*.patch-$RVER" | sort); do
	echo "applying patch file $a"
	patch -N -p1 -i $a
done
#	--enable-24-bit-color \

# CXXFLAGS="-std=gnu++11" LDFLAGS="-lm" ./configure \
LDFLAGS="-lm" ./configure \
	--prefix=/usr/local \
	--localstatedir=/var \
	--sysconfdir=/usr/local/etc \
	--with-x \
	--with-codesets=all \
	--disable-assert \
	--disable-warnings \
	--enable-256-color \
	--enable-wide-glyphs \
	--enable-unicode3 \
	--enable-combining \
	--enable-xft \
	--enable-font-styles \
	--disable-startup-notification \
	--enable-fading \
	--enable-rxvt-scroll \
	--enable-next-scroll \
	--enable-xterm-scroll \
	--disable-perl \
	--enable-xim \
	--enable-backspace-key \
	--enable-delete-key \
	--enable-resources \
	--disable-8bitctrls \
	--enable-fallback \
	--disable-swapscreen \
	--enable-iso14755 \
	--enable-frills \
	--enable-keepscrolling \
	--enable-selectionscrolling \
	--enable-mousewheel \
	--enable-slipwheeling \
	--enable-smart-resize \
	--enable-text-blink \
	--enable-pointer-blank \
	$XP || exit

. $MEDIR/phase-default-make.sh

make install DESTDIR=$TCZ

chmod -R ug+w $TCZ

mkdir -p $TCZ-doc/usr/local/share/contrib
mv $TCZ/usr/local/share/man $TCZ-doc/usr/local/share
cp $BASE/contrib/color-256-test.sh $TCZ-doc/usr/local/share/contrib

cat << EOF > $TCZ/usr/local/bin/rxvt-unicode
#!/bin/busybox sh

######################################################
# rxvt xterm wrapper for Tiny Core Linux
######################################################

urxvt +tr "\$@"
EOF
chmod 755 $TCZ/usr/local/bin/rxvt-unicode

mkdir -p $TCZ/usr/local/share/applications

cat << EOF > $TCZ/usr/local/share/applications/rxvt.desktop
[Desktop Entry]
Encoding=UTF-8
Name=Rxvt-Unicode Terminal
Comment=Use the command line
GenericName=Terminal
Exec=urxvt
Terminal=false
Type=Application
#StartupNotify=true
Keywords=console;command line;execute;
X-FullPathIcon=/usr/local/share/pixmaps/rxvt.png
Icon=rxvt
OnlyShowIn=Old;
Categories=System;
EOF

mkdir -p $TCZ/usr/local/share/pixmaps

cp $BASE/contrib/rxvt.png $TCZ/usr/local/share/pixmaps/rxvt.png
chmod 644 $TCZ/usr/local/share/pixmaps/rxvt.png

mkdir -p $TCZ/usr/local/tce.installed

cat << EOF > $TCZ/usr/local/tce.installed/rxvt
#!/bin/sh
[ -f /usr/local/bin/xterm ] || ln -s /usr/local/bin/rxvt-unicode /usr/local/bin/xterm
EOF

mkdir -p $TCZ/usr/local/share/terminfo
tic -x -o $TCZ/usr/local/share/terminfo doc/etc/rxvt-unicode.terminfo
#chmod 644 $TCZ/usr/local/share/terminfo/r/rxvt-unicode

mkdir -p $TCZ/usr/local/lib
cp -a /usr/local/lib/libptytty.so* $TCZ/usr/local/lib

mkdir -p $TCZ-dev/usr/local/include $TCZ-dev/usr/local/lib/pkgconfig $TCZ-dev/usr/local/share/man/man3
cp /usr/local/include/libptytty.h $TCZ-dev/usr/local/include
cp /usr/local/lib/pkgconfig/libptytty.pc $TCZ-dev/usr/local/lib/pkgconfig
cp /usr/local/share/man/man3/libptytty.3 $TCZ-dev/usr/local/share/man/man3

. $MEDIR/phase-default-strip.sh
. $MEDIR/phase-default-set-perms.sh

sudo chown -R root.staff $TCZ/usr/local/tce.installed
sudo chmod -R 775 $TCZ/usr/local/tce.installed

. $MEDIR/phase-default-squash-tcz.sh

