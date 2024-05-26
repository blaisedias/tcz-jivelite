#!/usr/bin/env sh
echo "This script creates a backup of the installation of jivelite on piCorePlayer"
echo "Use the partner script restore-jivelite.sh to restore this backup"
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

ts=$(date | sed -e 's# #-#g' -e 's#:#-#g')
backupfile="jivelite-backup-${ts}.tar"
echo "This script will create the backup file ${PWD}/${backupfile}"
echo "press y then <enter> to proceed."
echo "Press <enter> to cancel"
IFS= read -r line
if [ "$line" != "y" ];  then
    echo "Cancelled!"
    exit 1
fi
tar cvf $backupfile /home/tc/.jivelite optional/pcp-jivelite*
echo "Created $backupfile"
