# Overview
For now pre-built tcz images are available on google drive see Installation steps below.

# Installation
Note: Installing these images overwrites jivelite images and settings,
to restore to stock settings either
* Uninstall JiveLite and install JiveLite again
* Back up jivelite tczs and settings by copying them before installing
  * `/home/tc/.jivelite` ( backup this directory tree)
  * `/mnt/.../tce/optional/*jivelite*` ( backup these files)
 
To avoid conflicts in settings it is best to do a clean install.

## Pre-requisites
* piCorePlayer version 9.0+
* JiveLite *MUST* be installed using the piCorePlayer web interface.
* If required, the display must be setup to work correctly.
  * This version of JiveLite uses display resolution as determined by SDL. See [Display Resolution and skin selection](#display-resolution-and-skin-selection) below. 
* The tce partition should have at least 512MiB free space.
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

When piCorePlayer restarts the forked version JiveLite will start.

## Post install
After JiveLite has started successfully it is recommended to resize all visualiser images
 see [README.visualiser](https://github.com/blaisedias/jivelite/blob/visu-4/README.visualiserapplet.md)

This will yield a smoother UI experience.

On a Raspberry PI zero W this will complete in around 20 minutes

Similarly when the skin selection is changed it recommended practice to resize all visualiser images.

## Version information
Version information is encoded in 2 parts, and can be determined by sshing into piCorePlayer
* lua code
 * `cat /opt/jivelite/build.txt`
* jivelite binary
 * `less /var/log/pcp_jivelite.log` and search for `src:rev`

The script `/opt/jivelite/bin/pcp-jivelite-info.sh` prints this information in a terminal.

For example
```
tc@raspi-zero-2W:~$ /opt/jivelite/bin/pcp-jivelite-info.sh 
- System ------------------------------
Linux raspi-zero-2W 6.1.77-pcpCore-v8 #12 SMP PREEMPT Wed Feb 14 22:25:17 EST 2024 aarch64 GNU/Linux
- Free Space --------------------------
Filesystem                Size      Used Available Use% Mounted on
tmpfs                   376.4M     19.1M    357.3M   5% /
/dev/mmcblk0p2           11.2G      3.4G      7.3G  32% /mnt/mmcblk0p2
tmpfs                   376.4M     19.1M    357.3M   5% /
- Build -------------------------------
Wed, 29 May 2024 23:17:47 +0100
git remote -v
origin  https://github.com/blaisedias/jivelite.git (fetch)
origin  https://github.com/blaisedias/jivelite.git (push)
git rev-parse HEAD
b00fc3186d6ba71927a0820adeaa2b2f2b7df36b
git rev-parse HEAD:share/jive
cc5b0b38838386e74a2bbfd44b0e00c9ecfc7938
git rev-parse HEAD:src
9e2541c000f6f3030dfa28debaaf2bf34a6fdb6a
git rev-parse HEAD:assets
32cb6924126ed0273e80b336b3d3cd0384e69fbd
- jivelite binary ---------------------
JiveLite 8.0.0-visu-4-r489 src:rev:9e2541c000f6f3030dfa28debaaf2bf34a6fdb6a
features:
        : savePNG
        : fontSelection
        : displaySize
        : altImageLoad
display resolution: 1024x600 BitsPerPixel:32 wmAvailable:0
jiveL_font_default fonts/Nunito/Nunito-Regular.ttf
---------------------------------------
tc@raspi-zero-2W:~$
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

If the display size reported by SDL is >= 1920x1080 the HD Grid Skin will also be available for selection.

Touch skins are absent from the selection because they are Joggler skins with different resolutions.

The resolution reported by SDL may not match the expected values.
For example when connected to a television, SDL reported the resolution as 1824x984 instead of the expected 1920x1080.

The fix is to set the Frame Buffer size to desired resolution using the piCorePlayer web interface, Tweaks->Jivelite Setup->Set Size

*Note*: the jivelite binary currently caps the resolution to 1920x1080.

## Image Resize
This version of JiveLite resizes visualisation images to match the display resolution.

Resizing images is not instantaneous and adds significant latency to the user 
interface.

To combat this the output of resizing is cached.

On desktop systems the resized images are cached in
`/home/<username>/.jivelite/userpath/cache/resized`

This caching is persistent across system restarts.

On piCorePlayer this is path not persistent.
If it were made persistent, it would affect backing up adversely in terms of time.

It can be added to the set of paths backed up, and persisted - typically using the command `pcp bu` or `filetool.sh`

However the presence of the disk image cache has the side-effects:
* longer backup times
* larger mydata.tgz files
* the disk image cache exists in RAM file-system so consumes RAM

### Persistent resized image cache on a partition
It is possible to create a persistent resized image cache by changing the location
of the resized image cache to a path on a piCorePlayer SD Card.

To address this, the concept of a JiveLite visualiser workspace has been introduced.

If a workspace is set JiveLite will save resized images at locations under the workspace
instead of `/home/<username>/.jivelite/userpath/cache/resized`

The trade-off is that JiveLite will write to the piCorePlayer SD Card when an image is resized.

Saving resized images isn't a frequent activity - it would occur once for each resource image and visualisation viewport combination,
and is deemed a worthy trade-off.

Resize can be done en-block see [README.visualiser](https://github.com/blaisedias/jivelite/blob/visu-4/README.visualiserapplet.md)

The workspace directory can be configured in the JiveLite UI, see menuitem `Workspace` in the `Visualiser` settings menu.
This is a setting, and can be made persistent by backup (`pcp bu`). It is advisable to restart JiveLite after changing
the workspace setting.

### workspace layout
* `cache/resized` : resized visualisation images are stored here
* `assets` : custom user visualisation can be stored here. The layout is identical to `assets`
  * `assets/visualisers/`
  * `assets/visualisers/spectrum/backlit/`
  * `assets/visualisers/spectrum/gradient/`
  * `assets/visualisers/vumeters/analogue/`
  * `assets/visualisers/vumeters/vfd/`

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
It is possible to remove the need for resizing on the target system completely by rebuilding pcp-jivelite.tcz using squashfs.

Doing this removes the negative impacts of
 * longer backup times
 * larger mydata.tgz files

The procedure is 
* run JiveLite on a desktop or laptop
* select the desired skin and resolution
* resizing all images see [README.visualiser](https://github.com/blaisedias/jivelite/blob/visu-4/README.visualiserapplet.md)
* repeat the previous 2 steps for other skins if applicable
* expand pcp-jivelite.tcz - to get a tree of files and directories
* copy the images from 
  * `~/.jivelite/userpath/resized_cache`
  * TO
  * `opt/jivelite/assets/resized` in the tree created by expanding pcp-jivelite.tcz
* rebuild pcp-jivelite.tcz from the tree
* install the rebuilt pcp-jivelite.tcz

## Stale cache entries
Once a resized image is cached the original artwork will not be loaded again by JiveLite.

If the original artwork is changed the cached resized image is now "stale".

To rectify this is to ssh into piCorePlayer and delete the resized images.
Resized images have names including the name of the original artwork.
Restart JiveLite

Alternatively, the JiveLite UI supports deleting resized images (deletes all images) [visualiserapplet](https://github.com/blaisedias/jivelite/blob/visu-4/README.visualiserapplet.md)
# Known issues
1)Resizing images on the target can produce stutters in the UI in the NowPlaying views.

To a large extent this has been addressed by caching the output of resize operations so should occur just once

Even with caching loading a resized image consumes time, and can result in a noticeable delay.

2) When the wallpaper is changed, transitioning to NowPlaying view with VUMeters results in sluggish VU Meter rendering.

The workaround is to cycle through NowPlaying views.

# Building
To build the visu-4 variant, use the script `build-visu4.sh`

Note this will *always* remove the jivelite tree, and pull the visu-4 branch from https://github.com/blaisedias/jivelite afresh.

