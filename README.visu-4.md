# Overview
For now pre-built `tcz` images are available on google drive see Installation steps below.

# Installation
Note: Installing these images overwrites JiveLite images and settings,
to restore to stock settings either
* Uninstall JiveLite and install JiveLite again
* Back up JiveLite `tcz` images and settings by copying them before installing
  * `/home/tc/.jivelite` ( backup this directory tree)
  * `/mnt/.../tce/optional/*jivelite*` ( backup these files)
 
To avoid conflicts in settings it is best to do a clean install. See [Pre-requisites](#pre-requisites)

## Pre-requisites
* piCorePlayer version 9.0+
* JiveLite *MUST* be installed using the piCorePlayer web interface.
* If required, the display must be setup to work correctly.
  * This version of JiveLite uses display resolution as determined by SDL. See [Display Resolution and skin selection](#display-resolution-and-skin-selection) below. 
* Previous settings - if any should be removed, to do this ssh into piCorePlayer and type the following command
```
rm -f /home/tc/.jivelite/userpath/settings/*
```

## Installation steps
ssh into piCorePlayer, then type the following commands
```
ce
wget https://raw.githubusercontent.com/blaisedias/tcz-jivelite/visu-4/install-visu-4.sh && chmod +x install-visu-4.sh
./install-visu-4.sh
```

Follow the instructions on the screen.

Then reboot, when piCorePlayer restarts the forked version JiveLite will start.

## Post install
For the previous releases, the recommendation was to resize all visualiser prior to playing music for a smooth user experience.

This is not necessary now, resizing occurs concurrently and the user interface is not locked up whilst an image is being resized.

Note: whilst the resized image is not available an `in progress` animation is displayed.

Resizing all visualiser images is supported, 
 see [README.visualiser](https://github.com/blaisedias/jivelite/blob/visu-4/README.visualiserapplet.md)

## jivelite.sh customisation
The previous releases contained a number of modifications to `jivelite.sh` (the script invoked to launch JiveLite) to support setup.

That functionality has been moved into the JiveLite UI and settings.

The version of `jivelite.sh` now contains a single modification to invoke the script `/home/tc/jivelite-custom.sh`

This is simpler, more flexible and maintainable approach to customising setup prior to launching JiveLite.

Included in this repository is an example of this script see `example-jivelite-custom.sh` or on pCP `cat /opt/jivelite/example-jivelite-custom.sh`

## Version information
Version information is encoded in 2 parts, and can be determined by logging into the piCorePlayer terminal using ssh
* lua code
 * `cat /opt/jivelite/build.txt`
* JiveLite binary
 * `less /var/log/pcp_jivelite.log` and search for `src:rev`

The script `/opt/jivelite/bin/pcp-jivelite-info.sh` prints this information in a terminal.

For example
```
tc@raspi-zero-2W:~$ /opt/jivelite/bin/pcp-jivelite-info.sh
- System ------------------------------
Linux raspi-zero-2W 6.1.77-pcpCore-v8 #12 SMP PREEMPT Wed Feb 14 22:25:17 EST 2024 aarch64 GNU/Linux
- Free Space --------------------------
Filesystem                Size      Used Available Use% Mounted on
tmpfs                   419.6M     24.4M    395.2M   6% /
/dev/mmcblk0p2           11.2G      1.3G      9.4G  12% /mnt/mmcblk0p2
tmpfs                   419.6M     24.4M    395.2M   6% /
- Build -------------------------------
Tue, 08 Oct 2024 21:27:40 +0100
git remote -v
origin  https://github.com/blaisedias/jivelite.git (fetch)
origin  https://github.com/blaisedias/jivelite.git (push)
git rev-parse HEAD
10f44682e15bc46fad7872084688fb7650e1d5d9
git rev-parse HEAD:share/jive
ab01a7fa8615a9e4908b7b2076a0128bd2d5940f
git rev-parse HEAD:src
b33c269619a5a91ca4d19ee28a1c400aa253fbcd
git rev-parse HEAD:assets
e014105952280a31e3c69099fc039dba12a4f742
- jivelite binary ---------------------
JiveLite 8.0.0-visu-4-r542 src:rev:b33c269619a5a91ca4d19ee28a1c400aa253fbcd
features:
        : savePNG
        : fontSelection
        : displaySize
        : altImageLoad
started resizer thread
display:
        resolution: 1024x600
        BitsPerPixel:32,
        BytesPerPixel:4
---------------------------------------
```

## Display Resolution and skin selection
The display size and presence of Window Manger reported by SDL
is recorded and used selected the skin resolution.

If a Window Manager is not present as on piCorePlayer then, the display size is used for screen width and height.

This information is made available at the bottom of the Settings->Screen menu.

Then typically 3 skin choices will be presented
* Grid Skin
* HD Skin
* Joggler Skin

If the display size reported by SDL is >= 1920x1080 then the `HD Grid Skin` will also be available for selection.

Touch skins appear to be absent, but they are represented by `Joggler skin` selection, because that is what they were, Joggler skins at different resolutions.

The resolution reported by SDL may not match the expected values.
For example when connected to a television, SDL reported the resolution as 1824x984 instead of the expected 1920x1080.

The fix is to set the Frame Buffer size to desired resolution using the piCorePlayer web interface, Tweaks->Jivelite Setup->Set Size

*Note*: the JiveLite binary currently caps the resolution to 1920x1080.

## Image Resize
This version of JiveLite resizes visualisation images to match the display resolution.

Resizing images is not instantaneous and adds latency to the user interface.

To combat this the output of resizing is cached.

On desktop systems the resized images are cached in
`/home/<username>/.jivelite/userpath/cache/resized`

This caching is persistent across system restarts.

On piCorePlayer this is path not persistent.
If it were made persistent, it would affect backing up adversely in terms of time.

It can be added to the set of paths backed up, and persisted - typically using the command `pcp bu` or `filetool.sh`

However the presence of the disk image cache has the side-effects:
* longer backup times
* larger `mydata.tgz` files
* the disk image cache exists in RAM file-system so consumes RAM

### Persistent resized image cache on a partition
It is possible to store resized images persistently without the aforementioned drawbacks, 
by changing the location where the resized images are stored to one the piCorePlayer SD Card.

To address this, the concept of a JiveLite visualiser workspace has been introduced.

If a workspace is set JiveLite will save resized images at locations under the workspace
instead of `/home/<username>/.jivelite/userpath/cache/resized`

The trade-off is that JiveLite will write to the piCorePlayer SD Card when an image is resized.

Saving resized images is not a frequent activity - it should occur once for each resource image and visualisation viewport combination,
and is deemed a worthy trade-off.

Resizing can be done en-block see [README.visualiser](https://github.com/blaisedias/jivelite/blob/visu-4/README.visualiserapplet.md)

The workspace directory can be configured in the JiveLite UI, see menu item `Workspace` in the `Visualiser` settings menu.
This setting should be made persistent by backing up (`pcp bu`).
It is advisable to restart JiveLite after changing
the workspace setting.

### workspace layout
* `cache/resized` : resized visualisation images are stored here
* `assets` : custom user visualisation can be copied here. The layout is identical to `assets` in the jivelite repo

Alternatively see `Resizing images prior to deployment` below.

## Adding Spectrum Analyzer and VU Meters
The presence of the workspace directory was used as an opportunity to make it easier to adding custom visualisation artwork for JiveLite on piCorePlayer.

Simply copy artwork files to the appropriate location in the workspace path and restart JiveLite.

Typically (but not always) these paths are

* `/mnt/mmcblk0p2/tce/jivelite-workspace/assets/visualisers/spectrum/backlit`
* `/mnt/mmcblk0p2/tce/jivelite-workspace/assets/visualisers/spectrum/gradient`
* `/mnt/mmcblk0p2/tce/jivelite-workspace/assets/visualisers/vumeters/vfd`
* `/mnt/mmcblk0p2/tce/jivelite-workspace/assets/visualisers/vumeters/analogue`

### Resizing images offline
It is possible to remove the need for resizing on the target system completely by rebuilding `pcp-jivelite.tcz` using `squashfs`.

Doing this removes the negative impacts of
 * longer backup times
 * larger `mydata.tgz` files

The procedure is 
* run JiveLite on a desktop or laptop
* select the desired skin and resolution
* resizing all images see [README.visualiser](https://github.com/blaisedias/jivelite/blob/visu-4/README.visualiserapplet.md)
* repeat the previous 2 steps for other skins if applicable
* expand `pcp-jivelite.tcz` - to get a tree of files and directories
* copy the images from 
  * `~/.jivelite/userpath/resized_cache`
  * TO
  * `opt/jivelite/assets/resized` in the tree created by expanding `pcp-jivelite.tcz`
* rebuild `pcp-jivelite.tcz` from the tree
* install the rebuilt `pcp-jivelite.tcz`

## Stale cache entries
Once a resized image is cached the original artwork will not be loaded again by JiveLite.

If the original artwork is changed the cached resized image is now "stale".

To rectify this is to ssh into piCorePlayer and delete the resized images.
Resized images have names including the name of the original artwork.
Restart JiveLite

Alternatively, the JiveLite UI supports deleting resized images (deletes all images) [visualiserapplet](https://github.com/blaisedias/jivelite/blob/visu-4/README.visualiserapplet.md)

# Known issues
1) Resizing images on the target can produce stutters in the UI in the `NowPlaying` views.

To a large extent this has been addressed by caching the output of resize operations so should occur just once

Even with caching loading a resized image consumes time, and can result in a noticeable delay.

2) When the wallpaper is changed, transitioning to `NowPlaying` view with `VUMeters` sometimes results in sluggish VU Meter rendering.

The workaround is to cycle through `NowPlaying` views.

# Building
To build the `visu-4` variant, use the script `build-visu4.sh`

Note this will *always* remove the source code tree, and pull the `visu-4` branch from https://github.com/blaisedias/jivelite afresh.

