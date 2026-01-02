if [ "$KBITS" == 32 ] ; then
	export CC="gcc -flto -fuse-linker-plugin -march=$MARCH -mtune=$MARCH -Os -pipe"
	export CXX="g++ -flto -fuse-linker-plugin -march=$MARCH -mtune=$MARCH -Os -pipe -fno-exceptions -fno-rtti"
else
	export CC="gcc -flto -fuse-linker-plugin -mtune=generic -Os -pipe"
	export CXX="g++ -flto -fuse-linker-plugin -mtune=generic -Os -pipe -fno-exceptions -fno-rtti"
fi

