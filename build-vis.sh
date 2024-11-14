#!/bin/sh

# for now build-vis requires a branch
if [ "$1" == "" ] ; then
    echo "Usage $0 <branch>"
    exit 1
fi

set -euxo pipefail

tce-load -w bash
tce-load -w patchelf.tcz
tce-load -w squashfs-tools
tce-load -w git
tce-load -w libasound-dev 
tce-load -w patchelf
tce-load -w pcp-squeezeplay
tce-load -w pcp-squeezeplay-dev
tce-load -w pcp-lirc-dev
tce-load -w pcp-lirc
tce-load -w compiletc

# # patchelf isn't present in 14.x, yet!
# # use copies downloaded from 13.x
# ARCH=$(uname -m)
# 
# if [ "$ARCH" == "aarch64" ]; then
#     cd ./pcp13.x/$ARCH
#     tce-load -i patchelf.tcz
#     cd ../../
# else
#     cd ./pcp13.x/armv6hf
#     tce-load -i patchelf.tcz
#     cd ../../
# fi

tce-load -il bash
tce-load -il squashfs-tools
tce-load -il git
tce-load -il libasound-dev 
tce-load -il patchelf
tce-load -il pcp-squeezeplay
tce-load -il pcp-squeezeplay-dev
tce-load -il pcp-lirc-dev
tce-load -il pcp-lirc
tce-load -il compiletc

./cleanup.sh
./create-jivelite-vis-tcz.sh "$1"
