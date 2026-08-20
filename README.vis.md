# Overview 
This document contains additional information for jivelite-vis when run on piCorePlayer.

jivelite-vis is a variant of jivelite see https://github.com/ralph-irving/jivelite.

For more information on jivelite-vis, see https://github.com/blaisedias/jivelite/blob/vis/README.thisfork.md

# Installation
jivelite-vis is available for installation from piCorePlayer 10.0 onwards.

It can be installed using the Tweaks tab on piCorePlayer web interface.

It cannot be installed alongside jivelite.

# Terms and conventions
For the remainder of this document the word JiveLite will be used to refer to jivelite-vis
  
## Post install
By default on piCorePlayer JiveLite contains a single VU Meter and single colour Spectrum Meters.

Additional VU and Spectrum Meters can be installed by installing `vis-VU_Meter...` and `vis-SP_Meter...` packages.

A list visualiser suites and names of packages is available here https://github.com/blaisedias/tcz-jivelite-visualisers/blob/main/list.md
 
## Display resolution and skin selection
The display size and presence of Window Manger reported by SDL
is recorded and used to select the skin resolution.

A Window Manager is absent on piCorePlayer, so the display size is used for screen width and height.

This information is made available at the bottom of the Settings->Screen menu.

On installation typically 2 skin choices will be presented
* Grid Skin
* Joggler Skin

Touch skins appear to be absent, they are represented by `Joggler skin` selection, because that is what they are: Joggler skins at different resolutions.

The resolution reported by SDL may not match the expected values.
For example when connected to a television, SDL reported the resolution as 1824x984 instead of the expected 1920x1080.

The fix is to set the Frame Buffer size to desired resolution using the piCorePlayer web interface, Tweaks->Jivelite Setup->Set Size

*Note*: the JiveLite binary currently caps the resolution to 1920x1200.

## Image Resize
JiveLite resizes visualiser images to fit the display.

The resizing process takes a noticeable amount of time to complete.

To prevent user interface locking up, resizing is performed as a background task

Typically whilst a visualiser resized image is not available and is being resized, an `in progress` animation is displayed.

Since resizing images is not instantaneous, and adds latency to the user interface the output of resizing is cached for future use.

Resized images are cached in
`/home/<username>/.jivelite/userpath/cache/resized`

On piCorePlayer this is path not persistent.

If it were made persistent, it would have the following negative side-effects:
* longer backup times
* larger `mydata.tgz` files
* the disk image cache exists in RAM file-system so consumes RAM

### Persistent resized image cache on a partition
It is possible to store resized images persistently without the aforementioned drawbacks,
by changing the location where the resized images are stored to one on the piCorePlayer SD Card.

To address this, the concept of a JiveLite visualiser workspace has been introduced.

If a workspace is set, JiveLite will save resized images at locations under the workspace
instead of `/home/<username>/.jivelite/userpath/cache/resized`

The SD Card partition should have enough space to hold the resized visualiser images. It is very likely that the default partition size is too small.

Using a workspace on the SD card alters the behaviour of JiveLite in that it now writes to SD card instead of running entirely in RAM.

This means that tt is possible that whilst writing resized images, a loss of power could result in a corrupted SD card partition. Whilst corruption unlikely - the user should be aware that such a possibility exists.

Saving resized images is not a frequent activity - it should occur once for each resource image and visualisation viewport combination,
and is deemed a worthy trade-off.

The workspace directory can be configured in the JiveLite UI, see menu item `Workspace` in the `Visualiser` settings menu.
This setting should be made persistent by backing up (`pcp bu`).
JiveLite should be restarted after changing the workspace setting.

It is possible to resize all visualiser prior to playing music for a smoother user experience.
See [README.visualiser](https://github.com/blaisedias/jivelite/blob/vis/README.visualiserapplet.md)

#### Mitigating the impact of using a workspace on SD card
* Resize all visualisers, thus reducing the likelihood of power loss during writing resized images.
* Use a 3rd partition as location for the workspace.

### Workspace layout
* `cache/resized` : resized visualisation images are stored here
* `assets` : custom user visualisation can be copied here. The layout is identical to `assets` in the jivelite repo

## Adding Spectrum Analyzer and VU Meters using the workspace
The presence of the workspace directory was used as an opportunity to make it easier to add custom visualisation artwork for JiveLite on piCorePlayer.

Simply copy artwork and json files to the appropriate location in the workspace path and restart JiveLite.

Typically (but not always) these paths are

* `/mnt/mmcblk0p2/tce/jivelite-workspace/assets/visualisers/spectrum`
* `/mnt/mmcblk0p2/tce/jivelite-workspace/assets/visualisers/vumeters`

For example copy all files for a VU Meter to `/mnt/mmcblk0p2/tce/jivelite-workspace/assets/visualisers/vumeters/vumeter-1`

## Stale cache entries
Once a resized image is cached the original artwork will not be loaded again by JiveLite.

If the visualiser artwork is updated the cached resized image are now stale.

If the artwork files have md5sum files associated (by name), JiveLite will generate new resized images for the updated artwork. (Note: stale files are not deleted).

If the artwork files do not have md5sum files then user intervention is required to delete the stale resized images.

The JiveLite UI supports deleting all resized images [see visualiserapplet](https://github.com/blaisedias/jivelite/blob/vis/README.visualiserapplet.md)

The Jivelite UI does not support deleting of specific resized images.

To do that, ssh into piCorePlayer and delete the resized images and restart JiveLite.

Resized images have names including the name of the original artwork.


## Version information
Version information is encoded in 2 parts, and can be determined by logging into the piCorePlayer terminal using ssh
* lua code
 * `cat /opt/jivelite/build.txt`
* JiveLite binary
 * `less /var/log/pcp_jivelite.log` and search for `src:rev`

The script `/opt/jivelite/bin/pcp-jivelite-info.sh` prints this information in a terminal.

For example
```
tc@raspberrypi2:~$ /opt/jivelite/bin/pcp-jivelite-info.sh
- System ------------------------------
Linux raspberrypi2 6.12.67-pcpCore-v7 #36 SMP Sun Feb  1 17:08:00 EST 2026 armv7l GNU/Linux
- Free Space --------------------------
Filesystem                Size      Used Available Use% Mounted on
tmpfs                   828.9M     24.7M    804.2M   3% /
/dev/mmcblk0p2           14.3G      2.0G     11.5G  15% /mnt/mmcblk0p2
- Build -------------------------------
Fri, 15 May 2026 19:29:54 +0100
tcz_jivelite:
    git repository=https://github.com/blaisedias/tcz-jivelite.git branch=vis
    tags=vis-release-2.1.1
    git rev-parse HEAD=fbbfda36ba63bd216f32df2e5299fb10d75fc7fa
jivelite:
    git repository=https://github.com/blaisedias/jivelite.git branch=improve_jiiffies
    git rev-parse HEAD=984e7a492345581315bd731914f07cc86830180d
    git rev-parse HEAD:share/jive=fd712ca692696c381ff24ad4880c79fdc0b8846c
    git rev-parse HEAD:src=160bc68a1d45705603251ae795b12412e05c94fb
- jivelite binary ---------------------
JiveLite 8.1.0-improve_jiiffies-r895 src:rev: 160bc68a1d45705603251ae795b12412e05c94fb
git remote           : github.com/blaisedias/jivelite.git
git branch           : improve_jiiffies
git head revision    : 984e7a492345581315bd731914f07cc86830180d
build platform       : piCorePlayer 11.1.0
build platform cpe   : cpe:/o:picore:picore_linux:16.1
build platform arch  : armv7l
features:
        : savePNG
        : fontSelection
        : displaySize
        : altImageLoad
        : concurrent-resize
display:
        resolution: 1920x1080
        BitsPerPixel:16,
        BytesPerPixel:2
        Window manager:0,
        Hardware Acceleration:1
        video memory:4050 KiB
        jivelite frame rate:22 fps
---------------------------------------
```

# Known issues
1) Resizing images on the target can produce stutters in the UI in the `NowPlaying` views.

To a large extent this has been addressed by caching the output of resize operations, so should occur just once.

Even with caching loading a resized image consumes time, and can result in a noticeable delay.

2) When the wallpaper is changed, transitioning to `NowPlaying` view with `VUMeters` sometimes results in sluggish VU Meter rendering.

The workaround is to cycle through `NowPlaying` views.

# Building
To build the `vis` variant, use the script `build-vis.sh`

Note this will *always* remove the source code tree, and pull the `vis` branch from https://github.com/blaisedias/jivelite afresh.

