
cd src

cmake .. || exit

find . -name Makefile -type f -exec sed -i -e 's/-O2//g' {} \;

