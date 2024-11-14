#!/bin/sh

# Example jivelite customisation shell script
# This example sets up a touch screen.
# This script is not definitive and should
# be changed to match the hardware.
echo "# ---- { "
has_touch_screen=$(udevadm info --export-db | grep 'ID_INPUT_TOUCHSCREEN=1' | wc -l)
if [ "$has_touch_screen" != "0" ]; then
    echo "Touch screen detected" 
    ev=$(cat /proc/bus/input/devices | grep mouse | sed -e 's# $##' -e 's#^.* ##')
    echo "Touch screen setup: ev=${ev}" 
    if [ "$ev" != "" ] ; then
        echo "Touch screen setup: found mouse input device: $ev" 
        echo "export TSLIB_TSDEVICE=/dev/input/$ev" 
        export TSLIB_TSDEVICE=/dev/input/$ev

        echo "export SDL_MOUSEDRV=TSLIB" 
        export SDL_MOUSEDRV=TSLIB
   
        if [ -f '/usr/local/etc/pointercal' ]; then
            echo "export TSLIB_CALIBFILE=/usr/local/etc/pointercal"
            export TSLIB_CALIBFILE=/usr/local/etc/pointercal
            echo "Contents of pointercal"
            cat ${TSLIB_CALIBFILE}
            echo ""
        fi
    else
        echo "Touch screen setup: mouse input device not found"
    fi
else
    echo "Touch screen not detected" 
fi
unset has_touch_screen
echo "# } ----"
