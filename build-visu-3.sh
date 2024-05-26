#!/bin/sh
set -euxo pipefail

# create-jivelite-tcz.sh uses bash
#
tce-load -il bash
# patchelf isn't present in 14.x, yet!
# use copies downloaded from 13.x
ARCH=$(uname -m)

if [ "$ARCH" == "aarch64" ]; then
    cd ./pcp13.x/$ARCH
    tce-load -i patchelf.tcz
    cd ../../
else
    cd ./pcp13.x/armv6hf
    tce-load -i patchelf.tcz
    cd ../../
fi
tce-load -il squashfs-tools
tce-load -il git
tce-load -il libasound-dev 
tce-load -il patchelf
tce-load -il pcp-squeezeplay
tce-load -il pcp-squeezeplay-dev
tce-load -il pcp-lirc-dev
tce-load -il pcp-lirc
tce-load -il compiletc

./create-jivelite-tcz.sh visu-3
