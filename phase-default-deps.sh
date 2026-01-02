DEPS="compiletc bash file squashfs-tools $DEPS python$PYVER-dev $LZVER"

NOTFOUND=""
for a in $DEPS; do
##	ls -ld /usr/local/tce.installed
	tce-load -i $a || tce-load -iwl $a || NOTFOUND=x
done
test -z "$NOTFOUND" || exit

#sudo find /usr/lib -name '*.la' -exec rm -f {} \;
#sudo find /usr/local/lib -name '*.la' -exec rm -f {} \;

#sudo rm /usr/lib/*.la /usr/local/lib/*.la
