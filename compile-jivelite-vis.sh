#!/bin/bash

jivelitebranch=$1

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
    echo "########### compiling for $jivelitebranch ############"
	rm -rf jivelite
	git clone https://github.com/blaisedias/jivelite.git -b $jivelitebranch
    date -R > "${BUILD_TXT}"
    echo "tcz_jivelite:" >> "${BUILD_TXT}"
    x_remote=$(git remote  -v | grep fetch | sed -e 's#^origin\t##' -e 's# .*##')
    x_branch=$(git branch --show-current)
    tmp=$(git tag --points-at HEAD)
    if [ "$tmp" != "" ] ; then
        echo "    tags=$tmp" >> "${BUILD_TXT}"
    fi
    tmp=$(git rev-parse HEAD)
    echo "    git rev-parse HEAD=${tmp}" >> "${BUILD_TXT}"
    echo "    git repository=${x_remote} branch=${x_branch}" >> "${BUILD_TXT}"
	cd jivelite
    echo "jivelite:" >> "${BUILD_TXT}"
    x_remote=$(git remote  -v | grep fetch | sed -e 's#^origin\t##' -e 's# .*##')
    x_branch=$(git branch --show-current)
    echo "    git repository=${x_remote} branch=${x_branch}" >> "${BUILD_TXT}"
    tmp=$(git tag --points-at HEAD)
    if [ "$tmp" != "" ] ; then
        echo "    tags=$tmp" >> "${BUILD_TXT}"
    fi
    tmp=$(git rev-parse HEAD)
    echo "    git rev-parse HEAD=${tmp}" >> "${BUILD_TXT}"
    tmp=$(git rev-parse HEAD:share/jive)
    echo "    git rev-parse HEAD:share/jive=${tmp}" >> "${BUILD_TXT}"
    tmp=$(git rev-parse HEAD:src)
    echo "    git rev-parse HEAD:src=${tmp}" >> "${BUILD_TXT}"

	git submodule update --init --recursive

	### { Prune the set of visualiser resources to a minimum
	# Chevron Cyan Orange digital VU Meter, 
	tar cf /tmp/v.tar "assets/visualisers/vumeters/Chevrons Cyan Orange" assets/visualisers/spectrum/colours.json

# vis -release 1    
#	rm -rf  assets/visualisers/vumeters/*
#	rm -rf  assets/visualisers/spectrum/*
	
# vis -release 2
	rm assets/visualisers
	rm -rf  assets/tcz-jivelite-visualisers
	mkdir -p assets/visualisers
	mkdir -p assets/visualisers/vumeters
	mkdir -p assets/visualisers/spectrum

	tar xf /tmp/v.tar
	### }

	cd lib-src
	git clone https://github.com/ralph-irving/lirc-bsp
	cd ../
	patch -p1 -i../vis-jivelite-picoplayer-$CPU.patch || exit 1
#fi
# retrieve base version as delcared in src
base_binary_version=$(cat src/version.h  | sed -e 's/^.* //' | sed -e 's#"##g#' | sed -e 's#-vis##')
# retrieve tag - convention for tags is to include the branch if not built off master/main
git_version=$(git tag --points-at HEAD)
if [ "$git_version" == "" ] ; then
    # tip is untagged add branch-commit 
    tmp=$(git rev-list HEAD --count)
    git_version="${jivelitebranch}-r${tmp}"
fi
echo "#define JIVE_VERSION \"${base_binary_version}-${git_version}\"" > src/version.h
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
