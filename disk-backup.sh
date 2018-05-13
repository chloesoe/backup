#!/bin/bash

# inspired by: https://netfuture.ch/2013/08/simple-versioned-timemachine-like-backup-using-rsync/

#dirs without a slash at the end
sourcedir=/home/dhw
backupdir=/media/dhw/wd_ext4
logdir=/home/dhw/Backup/log
excludefile=/home/dhw/bin/backup-exclude.txt
label=dhw_`date +%Y-%m-%d_%A`

#int_handler makes sure, the after action with link is not take place
int_handler()
{
    echo "Interrupted."
    # Kill the parent process of the script.
    kill $PPID
    exit 1
}
trap 'int_handler' INT


if mount | grep $backupdir > /dev/null; then
    if [ -d "$backupdir/__prev/" ]; then
        rsync -avk --exclude-from=$excludefile --delete --log-file=$logdir/backup_$(date +'%Y%m%d').log --link-dest="$backupdir/__prev/" "$sourcedir/" "$backupdir/$label"
    else
        rsync -avk --exclude-from=$excludefile "$sourcedir/" "$backupdir/$label"
    fi
    rm -f "$backupdir/__prev"
    ln -s "$label" "$backupdir/__prev"
else
    echo "Backup drive not found!"
fi

echo "Backup Finished!"
read -p "Press ENTER to close"

# We never reach this part.
exit 0
