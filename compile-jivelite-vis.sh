#!/bin/bash

opt=$1

ARCH=$(uname -m)

case "$ARCH" in
        aarch64)
		export CPU=aarch64
                ;;
        *)
		export CPU=armv6hf
                ;;
esac

#if [ ! -d jivelite ]; then
#	git clone https://github.com/ralph-irving/jivelite.git
#	cd jivelite
#	patch -p1 -i../jivelite-picoplayer-$CPU.patch || exit 1
#	cd lib-src
#	git clone https://github.com/ralph-irving/lirc-bsp
#	cd ../
#else
#	cd jivelite
#	make PREFIX=/usr clean
#	patch -p1 -R -i../jivelite-picoplayer-$CPU.patch
#	git checkout src/version.h
#	git pull
#	patch -p1 -i../jivelite-picoplayer-$CPU.patch
#fi
#
#else
    echo "########### compiling for $opt ############"
	rm -rf jivelite
	git clone https://github.com/blaisedias/jivelite.git -b $opt
	cd jivelite
	git submodule update --init --recursive
	cd lib-src
	git clone https://github.com/ralph-irving/lirc-bsp
	cd ../
	patch -p1 -i../vis-jivelite-picoplayer-$CPU.patch || exit 1
    date -R > ./build.txt
    echo "git remote -v" >> ./build.txt
    git remote -v >> ./build.txt
    echo "git rev-parse HEAD" >> ./build.txt
    git rev-parse HEAD >> ./build.txt
    echo "git rev-parse HEAD:share/jive" >> ./build.txt
    git rev-parse HEAD:share/jive >> ./build.txt
    echo "git rev-parse HEAD:src" >> ./build.txt
    git rev-parse HEAD:src >> ./build.txt
    echo "git rev-parse HEAD:assets" >> ./build.txt
    git rev-parse HEAD:assets >> ./build.txt
#fi

# Set jivelite version to 8.0.0 to indicate slimdevices player lua applet compatibility.
#echo "#define JIVE_VERSION \"8.0.0-r$(git rev-list HEAD --count)\"" > src/version.h
echo "#define JIVE_VERSION \"8.0.0-$opt-r$(git rev-list HEAD --count)\"" > src/version.h
echo "#define SRC_GIT_REMOTE \"$(git remote -v)\"" > src/long_version.h
echo "#define SRC_GIT_BRANCH \"$(git branch --show-current)\"" >> src/long_version.h
echo "#define SRC_GIT_HEAD_REV \"$(git rev-parse HEAD)\"" >> src/long_version.h

make all || exit 2

if [ ! -d lua-5.1.5 ]; then
	tar -xzf ../squeezeplay-lua-5.1.5-src.tar.gz
	cd lua-5.1.5
	patch -p0 -i../../squeezeplay-lua-$CPU.patch || exit 1
else
	cd lua-5.1.5
	make clean
	patch -R -p0 -i../../squeezeplay-lua-$CPU.patch
	if [ "$ARCH" != "aarch64" ]; then
		svn up
	fi
	patch -p0 -i../../squeezeplay-lua-$CPU.patch
fi

make linux && exit 0
