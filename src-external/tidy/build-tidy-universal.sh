
# This is not used, the project uses the system-supplied libtidy for now

set -e

[ -e libtidy.a ] && exit

WD="$PWD"
echo working directory: $WD

if [ ! -e tidy-cvs ]; then
	cvs -d:pserver:anonymous:@tidy.cvs.sourceforge.net:/cvsroot/tidy login
	cvs -z3 -d:pserver:anonymous@tidy.cvs.sourceforge.net:/cvsroot/tidy co -d tidy-cvs -P tidy
fi

for arch in ppc i386 x86_64 ppc64; do
	echo =========================
	echo building for $arch

	rm -rf "$WD/tidy-cvs/bin"
	cd "$WD/tidy-cvs/build/gmake" 
	make clean
	OTHERCFLAGS="-arch $arch" make -e
	mv "$WD/tidy-cvs/lib/libtidy.a" "$WD/libtidy.a.$arch"
done

cd "$WD"
lipo -create libtidy.a.* -output libtidy.a

