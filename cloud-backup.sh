#!/bin/bash

# This backup script backups files with rsync to a storage through sshfs.
# Deleted files on source will be deleted on the destination ("--delete"
# parameter in rsync command). This script is reccommended to use as a second
# backup destinations

# dirs without a slash at the end
sourcedir=/home/dhw
backupdir=/media/dhw/hetzner
excludefile=/home/dhw/backup/cloud-exclude.txt
label=dhw
ssh_identiyfile=/home/dhw/.ssh/cloud_key
# storage url file has to look like "user@example.com"
ssh_storageurl=`cat /home/dhw/.ssh/storage_url`

#mount backup direcorty with sshfs
sshfs $ssh_storageurl:/ $backupdir -o IdentityFile=$ssh_identiyfile -o idmap=user -o uid=$(id -u) -o gid=$(id -g)

cd $sourcedir

# int_handler makes sure, the destination is unmounted
int_handler()
{
    echo "Interrupted."
    # Kill the parent process of the script.
    kill $PPID
    fusermount -u $backupdir
    exit 1
}
trap 'int_handler' INT


if mount | grep $backupdir > /dev/null; then
    rsync -avzk --delete --log-file=/home/dhw/backup/cloud-backup_$(date +'%Y%m%d').log --exclude-from=$excludefile "$sourcedir/" "$backupdir/$label"
else
    echo "Backup drive not found!"
fi

# unmount backup dirs
fusermount -u $backupdir

echo "Fertig!"
read -p "Drücke ENTER um dieses Fenster zu schliessen"

# We never reach this part.
exit 0
