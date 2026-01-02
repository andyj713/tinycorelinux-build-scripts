OL=s
if [ "$KBITS" == 32 ] ; then
	export CC="gcc -flto -fuse-linker-plugin -march=$MARCH -mtune=$MARCH -O$OL -pipe"
	export CXX="g++ -flto -fuse-linker-plugin -march=$MARCH -mtune=$MARCH -O$OL -pipe"
else
	export CC="gcc -flto -fuse-linker-plugin -mtune=generic -O$OL -pipe"
	export CXX="g++ -flto -fuse-linker-plugin -mtune=generic -O$OL -pipe"
fi

