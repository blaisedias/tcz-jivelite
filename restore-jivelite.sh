#!/usr/bin/env sh
echo "This script restores a previously archived installation of jivelite on piCorePlayer"
echo "from a backup created by the partner script backup-jivelite.sh"
echo "There are no guarantees associated with running this script!"
echo "Use at your own risk"

TCEMNT="/mnt/$(readlink /etc/sysconfig/tcedir | cut -d '/' -f3)"
if [ ${TCEMNT} == "" ] ; then
    echo "unable to establish path to tce on piCorePlayer"
    exit 1
fi

cd $TCEMNT || exit 1

TCEOPTIONAL="$TCEMNT/tce/optional"
echo "installation path: $TCEOPTIONAL"
if [ -d "$TCEOPTIONAL"  ]; then
    :
else
    echo "path $TCEOPTIONAL deos not exist"
    exit 1
fi

if [ -d "/home/tc/.jivelite"  ]; then
    :
else
    echo "path /home/tc/.jivelite deos not exist"
    exit 1
fi


if [ "$1" != "" ]; then
   echo "Warning: jivelite settings and jivelite binaries will be overwritten."
   echo "Warning: No checks are performed on the backup file"
   echo "press y then <enter> to proceed with the restoration."
   echo "Press <enter> to cancel"
   IFS= read -r line
   if [ "$line" != "y" ];  then
       echo "Cancelled!"
       exit 1
   fi
   tar -xvf "$1"
   sudo rm -rf /home/tc/.jivelite
   sudo mv home/tc/.jivelite /home/tc
   rmdir home/tc
   rmdir home
   echo "now reboot (sudo reboot) or (pcp br) or (pcp rb)"
else
    echo "Usage $0 <backup-file-name>"
    echo "<backup-file-name> must have been created using jivelite-backup.sh"
fi
