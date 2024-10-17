#!/bin/sh
DL_PATH=/tmp/dl-visu-4

function download {
    set -x 
    fileid=$1
    filename=$2
    curl -c ./cookie -s -L "https://drive.google.com/uc?export=download&id=${fileid}" > /dev/null
    curl -Lb ./cookie "https://drive.google.com/uc?export=download&confirm=`awk '/download/ {print $NF}' ./cookie`&id=${fileid}" -o ${DL_PATH}/${filename}
    rm ./cookie
    set +x 
}

#https://drive.google.com/drive/folders/1MaPu-zZno1rg65SvJv2F2auN-g6z1Gmo?usp=sharing

#https://drive.google.com/file/d/1-Tb5zU_DK4cTqhoSamt_qvspNjjO7QhT/view?usp=sharing
PCP_JIVELITE_32BIT="1-Tb5zU_DK4cTqhoSamt_qvspNjjO7QhT"
#https://drive.google.com/file/d/1oQcMxpAjEHrpWMQQ_ftlJEX6ixCBmbg4/view?usp=sharing
PCP_JIVELITE_32BIT_MD5="1oQcMxpAjEHrpWMQQ_ftlJEX6ixCBmbg4"
#https://drive.google.com/file/d/1nQoOs7Qp1ZgnIfUuCcBpmrj1l2IDuRT9/view?usp=sharing
PCP_JIVELITE_64BIT="1nQoOs7Qp1ZgnIfUuCcBpmrj1l2IDuRT9"
#https://drive.google.com/file/d/1OWg3OE5xkT8n4bkmkGOKz8lkdupdULng/view?usp=sharing
PCP_JIVELITE_64BIT_MD5="1OWg3OE5xkT8n4bkmkGOKz8lkdupdULng"
#https://drive.google.com/file/d/1_xRXJL4FamSv565ax8kPO5DUH7ir881v/view?usp=sharing
PCP_JIVELITE_HDSKINS="1_xRXJL4FamSv565ax8kPO5DUH7ir881v"
#https://drive.google.com/file/d/16w20p0g9O_d2iGj9D4taCKJJDGO-SafQ/view?usp=sharing
PCP_JIVELITE_HDSKINS_MD5="16w20p0g9O_d2iGj9D4taCKJJDGO-SafQ"

echo "This script, downloads and installs a forked version of jivelite"
echo "on top of an existing installation of jivelite on piCorePlayer"
echo ""

TCEMNT="/mnt/$(readlink /etc/sysconfig/tcedir | cut -d '/' -f3)"
if [ ${TCEMNT} == "" ] ; then
    echo "unable to establish path to tce on piCorePlayer"
    exit 1
fi

TCEOPTIONAL="$TCEMNT/tce/optional"
echo "installation path: $TCEOPTIONAL"
if [ -d "$TCEOPTIONAL"  ]; then
    :
else
    echo "path $TCEOPTIONAL deos not exist"
    exit 1
fi

machine=$(uname -m)
bitwidth=0
case ${machine} in
        aarch64)
                echo "CPU : 64 bit ARM"
                bitwidth=64
                ;;
        armv6l | armv7l)
                echo " CPU : 32 bit ARM"
                bitwidth=32
                ;;
        *)
                echo "unknown/unsupported CPU type: ${machine}"
                if [ "$1" != "" ] ; then
                    echo "WARNING: using command line bit width value $1"
                    bitwidth=$1
                else
                    exit 1
                fi
                ;;
esac

case "${bitwidth}" in 
    "32"|"64")
        :
        ;;
    *)
        echo "unsupported bit width ${bitwidth}"
        exit 1
esac

if [ -f "$TCEOPTIONAL/pcp-jivelite.tcz" ];
then
        echo ""
        echo "If the installation details are correct,"
        echo "press y then <enter> to proceed with the installation."
        echo "Press <enter> to cancel"

        IFS= read -r line
        if [ "$line" != "y" ];  then
                echo "cancelling"
                exit 1
        fi

        rm -rf ${DL_PATH}
        mkdir ${DL_PATH}
        cd $TCEOPTIONAL
        case $(uname -m) in
                armv6l | armv7l)
                        download ${PCP_JIVELITE_32BIT} pcp-jivelite.tcz
                        download ${PCP_JIVELITE_32BIT_MD5} pcp-jivelite.tcz.md5.txt
                ;;
                aarch64)
                        download ${PCP_JIVELITE_64BIT} pcp-jivelite.tcz
                        download ${PCP_JIVELITE_64BIT_MD5} pcp-jivelite.tcz.md5.txt
                ;;
                *)
                        echo "aborting.....unknown architecture"
                        exit 1
                ;;
        esac
        download ${PCP_JIVELITE_HDSKINS} pcp-jivelite_hdskins.tcz
        download ${PCP_JIVELITE_HDSKINS_MD5} pcp-jivelite_hdskins.tcz.md5.txt
        echo ""
        echo "checksums of new packages"
        ls ${DL_PATH}/pcp-jivelite* | sort | grep -v .dep | xargs sha1sum
        cd $TCEOPTIONAL
        echo ""
        echo "checksums of current packages:"
        ls pcp-jivelite* | sort | grep -v .dep | xargs sha1sum

        echo "press y then <enter> to proceed with the installation."
        echo "Press <enter> to cancel"
        IFS= read -r line
        if [ "$line" != "y" ];  then
                echo "Cancelled!"
                exit 1
        fi

        mv ${DL_PATH}/* .
        rmdir ${DL_PATH}
        echo "files copied!"
        echo "now reboot (sudo reboot) or (pcp br) or (pcp rb)"
else
        echo "please install jivelite before running this script"
fi

