#!/bin/bash
# improved 1. Apr. 2017 inspired from:
#   https://netfuture.ch/2013/08/simple-versioned-timemachine-like-backup-using-rsync/
# Usage: rsync-backup.sh <src> <dst> <label>

#dirs without a slash at the end
sourcedir=/home/dhw
backupdir=/media/dhw/wd_ext4
excludefile=/home/dhw/bin/backup-exclude.txt
label=dhw_`date +%Y-%m-%d_%A`

int_handler()
{
    echo "Interrupted."
    # Kill the parent process of the script.
    kill $PPID
    exit 1
}
trap 'int_handler' INT


#test if backupdir is mounted 
#if test -d $backupdir; then
if mount | grep $backupdir > /dev/null; then
    if [ -d "$backupdir/__prev/" ]; then
        #rsync -avk --checksum --delete --log-file=/home/dhw/backup/backup_$(date +'%Y%m%d').log --link-dest="$backupdir/__prev/" "$sourcedir/" "$backupdir/$label"
        rsync -avk --exclude-from=$excludefile --delete --log-file=/home/dhw/backup/backup_$(date +'%Y%m%d').log --link-dest="$backupdir/__prev/" "$sourcedir/" "$backupdir/$label"
    else
        rsync -avk --exclude-from=/$excludefile "$sourcedir/" "$backupdir/$label"
    fi
    rm -f "$backupdir/__prev"
    ln -s "$label" "$backupdir/__prev" > /home/dhw/backup/linklog_`date +%Y-%m-%d_%A`.txt
    #if test -d /run/media/dhw/wd_ext4/dhw/; then
else
    echo "Backup drive not found!"
fi

echo "Fertig!"
read -p "Drücke ENTER um dieses Fenster zu schliessen"

# We never reach this part.
exit 0
