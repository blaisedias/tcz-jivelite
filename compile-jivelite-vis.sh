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
    build_date=$(date -R)
    echo $build_date > "${BUILD_TXT}"

    echo "tcz_jivelite:" >> "${BUILD_TXT}"
    tcz_jl_remote=$(git remote  -v | grep fetch | sed -e 's#^origin\t##' -e 's# .*##')
    tcz_jl_branch=$(git branch --show-current)
    echo "    git repository=${tcz_jl_remote} branch=${tcz_jl_branch}" >> "${BUILD_TXT}"
    tcz_jl_tag=$(git tag --points-at HEAD)
    if [ "$tcz_jl_tag" != "" ] ; then
        echo "    tags=$tcz_jl_tag" >> "${BUILD_TXT}"
    fi
    tcz_jl_head=$(git rev-parse HEAD)
    echo "    git rev-parse HEAD=${tcz_jl_head}" >> "${BUILD_TXT}"

	cd jivelite
    echo "jivelite:" >> "${BUILD_TXT}"
    jl_remote=$(git remote  -v | grep fetch | sed -e 's#^origin\t##' -e 's# .*##')
    jl_tag=$(git tag --points-at HEAD)
    if [ "$jl_tag" != "" ] ; then
    	echo "    git repository=${jl_remote} tag=${jl_tag}" >> "${BUILD_TXT}"
    else
    	echo "    git repository=${jl_remote} branch=${jivelitebranch}" >> "${BUILD_TXT}"
    fi
    jl_head=$(git rev-parse HEAD)
    echo "    git rev-parse HEAD=${jl_head}" >> "${BUILD_TXT}"
    jl_head_share_jive=$(git rev-parse HEAD:share/jive)
    echo "    git rev-parse HEAD:share/jive=${jl_head_share_jive}" >> "${BUILD_TXT}"
    jl_head_src=$(git rev-parse HEAD:src)
    echo "    git rev-parse HEAD:src=${jl_head_src}" >> "${BUILD_TXT}"

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
sed -i -e "s/^local\s*version\s*=.*/local version=\"${base_binary_version}-${git_version}\"/" share/jive/jive/utils/version.lua
# add build info to version lua file
echo "" >>  share/jive/jive/utils/version.lua
echo "BuildInfo = {" >>  share/jive/jive/utils/version.lua
echo "'date: ${build_date}'," >>  share/jive/jive/utils/version.lua
echo "'tcz_jivelite:'," >>  share/jive/jive/utils/version.lua
echo "'  ${tcz_jl_remote}'," >>  share/jive/jive/utils/version.lua
echo "'  branch: ${tcz_jl_branch}'," >>  share/jive/jive/utils/version.lua
if [ "$tcz_jl_tag" != "" ] ; then
    echo "'  tag: ${tcz_jl_tag}'," >>  share/jive/jive/utils/version.lua
fi
echo "'  commits:'," >>  share/jive/jive/utils/version.lua
echo "'    ${tcz_jl_head}'," >>  share/jive/jive/utils/version.lua

echo "'jivelite:'," >>  share/jive/jive/utils/version.lua
echo "'  ${jl_remote}'," >>  share/jive/jive/utils/version.lua
echo "'  branch: ${jivelitebranch}'," >>  share/jive/jive/utils/version.lua
if [ "$jl_tag" != "" ] ; then
    echo "'  tag: ${jl_tag}'," >>  share/jive/jive/utils/version.lua
fi
echo "'  commits:'," >>  share/jive/jive/utils/version.lua
echo "'    ${jl_head}'," >>  share/jive/jive/utils/version.lua
echo "'  src:'," >>  share/jive/jive/utils/version.lua
echo "'    ${jl_head_src}'," >>  share/jive/jive/utils/version.lua
echo "'  share/jive:'," >>  share/jive/jive/utils/version.lua
echo "'    ${jl_head_share_jive}'," >>  share/jive/jive/utils/version.lua

echo "}" >>  share/jive/jive/utils/version.lua
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
