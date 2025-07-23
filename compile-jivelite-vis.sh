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
    date -R > "${BUILD_TXT}"
    echo "tcz_jivelite:" >> "${BUILD_TXT}"
    x_remote=$(git remote  -v | grep fetch | sed -e 's#^origin\t##' -e 's# .*##')
    x_branch=$(git branch --show-current)
    echo "    git repository=${x_remote} branch=${x_branch}" >> "${BUILD_TXT}"
	cd jivelite
    echo "jivelite:" >> "${BUILD_TXT}"
    x_remote=$(git remote  -v | grep fetch | sed -e 's#^origin\t##' -e 's# .*##')
    x_branch=$(git branch --show-current)
    echo "    git repository=${x_remote} branch=${x_branch}" >> "${BUILD_TXT}"
    tmp=$(git rev-parse HEAD)
    echo "    git rev-parse HEAD=${tmp}" >> "${BUILD_TXT}"
    tmp=$(git rev-parse HEAD:share/jive)
    echo "    git rev-parse HEAD:share/jive=${tmp}" >> "${BUILD_TXT}"
    tmp=$(git rev-parse HEAD:src)
    echo "    git rev-parse HEAD:src=${tmp}" >> "${BUILD_TXT}"

	### { Prune the set of visualiser resources to a minimum
	# Chevron Cyan Orange digital VU Meter, 
	tar cf /tmp/v.tar "assets/visualisers/vumeters/Chevrons Cyan Orange" assets/visualisers/spectrum/colours.json
	rm -rf  assets/visualisers/vumeters/*
	rm -rf  assets/visualisers/spectrum/*
	tar xf /tmp/v.tar
	### }

	git submodule update --init --recursive
	cd lib-src
	git clone https://github.com/ralph-irving/lirc-bsp
	cd ../
	patch -p1 -i../vis-jivelite-picoplayer-$CPU.patch || exit 1
#fi

# Set jivelite version to 8.0.0 to indicate slimdevices player lua applet compatibility.
#echo "#define JIVE_VERSION \"8.0.0-r$(git rev-list HEAD --count)\"" > src/version.h
echo "#define JIVE_VERSION \"8.0.0-$opt-r$(git rev-list HEAD --count)\"" > src/version.h
#echo "#define SRC_GIT_REMOTE \"$(git remote -v | grep fetch)\"" > src/long_version.h
#echo "#define SRC_GIT_BRANCH \"$(git branch --show-current)\"" >> src/long_version.h
#echo "#define SRC_GIT_HEAD_REV \"$(git rev-parse HEAD)\"" >> src/long_version.h

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
