OL=s
if [ "$KBITS" == 32 ] ; then
	export CC="gcc -march=$MARCH -mtune=$MARCH -O$OL -pipe"
	export CXX="g++ -march=$MARCH -mtune=$MARCH -O$OL -pipe -fno-exceptions -fno-rtti"
else
	export CC="gcc -mtune=generic -O$OL -pipe"
	export CXX="g++ -mtune=generic -O$OL -pipe -fno-exceptions -fno-rtti"
fi

